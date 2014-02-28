#include <google/protobuf/compiler/plugin.h>
#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <iostream>

// hack
#include <stdio.h>

#include "strutil.h"

using namespace std;
using namespace google::protobuf::compiler;
using namespace google::protobuf;

struct typeInfo {
	string delphiName;
	string writter;
	string reader;
	string wiretype;
};
struct typeInfo *typeinfo[18];
// taken from cpp_helpers.cc in protobuf
string StripProto(const string& filename) {
	if (HasSuffixString(filename, ".protodevel")) {
		return StripSuffixString(filename, ".protodevel");
	} else {
		return StripSuffixString(filename, ".proto");
	}
}
string PrivateFieldName(const FieldDescriptor *field) {
	// FIXME, prefix with F
	string out = field->camelcase_name();
	string::iterator i = out.begin();
	if ('a' <= *i && *i <= 'z') *i += 'A' - 'a';
	return "F"+out;
}
string PropertyName(const FieldDescriptor *field) {
	//cerr << "getting name for " << field->full_name() << "\n";
	if (field->name() == "_id") return "MongoId";
	string out = field->camelcase_name();
	string::iterator i = out.begin();
	if ('a' <= *i && *i <= 'z') *i += 'A' - 'a';
	return out;
}
/*void CreateArguments(io::Printer *printer,const Descriptor *message) {
	bool first = true;
	bool tick = false;
	for (int j=0; j<message->field_count(); j++) {
		const FieldDescriptor *field = message->field(j);
		if (!first) {
			if (tick) printer->Print("; ");
		} else first = false;
		tick = false;
		if (field->type() == FieldDescriptor::TYPE_BYTES) {
			if (field->label() != FieldDescriptor::LABEL_REPEATED) {
				printer->Print("const A$name$: TBytes","name",PrivateFieldName(field));
				tick = true;
			}
		} else if (field->type() == FieldDescriptor::TYPE_INT32) {
			if (field->label() != FieldDescriptor::LABEL_REPEATED) {
				printer->Print("const A$name$: Integer","name",PrivateFieldName(field));
				tick = true;
			}
		} else if (field->type() == FieldDescriptor::TYPE_STRING) {
			if (field->label() != FieldDescriptor::LABEL_REPEATED) {
				printer->Print("const A$name$: AnsiString","name",PrivateFieldName(field));
				tick = true;
			}
		} else if (field->type() == FieldDescriptor::TYPE_BOOL) {
			if (field->label() != FieldDescriptor::LABEL_REPEATED) {
				printer->Print("const A$name$: Boolean","name",PrivateFieldName(field));
				tick = true;
			}
		}
	}
}*/
void GenerateEnum(const EnumDescriptor *type, GeneratorContext* generator_context) {
	string name = type->name();
	scoped_ptr<io::ZeroCopyOutputStream> output(generator_context->Open("u" + type->name() + ".pas"));
	io::Printer printer(output.get(), '$');
	printer.Print(
		"unit u$name$;\n"
		"\n"
		"interface\n"
		"\n"
		"type\n"
		"  T$name$ = (\n"
		,"name",type->name());
	for (int j=0; j<type->value_count(); j++) {
		const EnumValueDescriptor *value = type->value(j);
		//cerr << value->name() << " = " << value->number() << "\n";
		char hack[10];
		snprintf(hack,9,"%d",value->number());
		const char *end = ",";
		if (j == (type->value_count()-1)) end = "";
		printer.Print(
			"    $name$ = $hack$$end$\n"
			,"name",value->name()
			,"hack",hack
			,"end",end);
	}
	printer.Print(
		"  );\n"
		"\n"
		"$begin$\n"
		"function TranslateServerCode(const ACode: Integer): String;\n"
		"$end$\n"
		"\n"
		"implementation\n"
		"\n"
		"$begin$\n"
		"uses System.SysUtils;\n"
		"\n"
		"function TranslateServerCode(const ACode: Integer): String;\n"
		"var\n"
		"  sc      : T$name$;\n"
		"  sc_valid: Boolean;\n"
		"begin\n"
		"  sc_valid := FALSE;\n"
		"  for sc := Low(TServerCodes) to High(TServerCodes) do\n"
		"    if Integer(sc) = ACode then\n"
		"    begin\n"
		"      sc_valid := TRUE;\n"
		"      Break;\n"
		"    end;\n"
		"\n"
		"  if not sc_valid then\n"
		"  begin\n"
		"    result := Format('UNKNOWN CODE [%d]', [ACode]);\n"
		"  end;\n"
		"\n"
		"  case TServerCodes(ACode) of\n"
		,"name",type->name()
		,"begin","{$IFDEF DEBUG}"
		,"end","{$ENDIF DEBUG}");
	for (int j=0; j<type->value_count(); j++) {
		const EnumValueDescriptor *value = type->value(j);
		printer.Print("    $name$: result := '$name$';\n","name",value->name());
	}
	printer.Print(
//		"  else\n"
//		"    result := Format('UNKNOWN CODE [%d]',[ACode]);\n"
		"  end;\n"
		"end;\n"
		"$end$\n"
		"\n"
		"end."
		,"end","{$ENDIF DEBUG}");
}
string EnumName(const FieldDescriptor *field) {
	string name = field->name();
	UpperString(&name);
	return "FN_"+name;
}
// some code based on http://sourceforge.net/p/protobuf-delphi/wiki/Example/
class BaseGenerator : public CodeGenerator {
	bool Generate(const FileDescriptor* file, const string& parameter, GeneratorContext* generator_context, string* error) const {
		for (int i=0; i<file->message_type_count(); i++) {
			const Descriptor *message = file->message_type(i);
			//cerr << "message#" << i << " " << message->name() << "\n";
			GenerateMessage(file,message,generator_context);
			for (int j=0; j<message->nested_type_count(); j++) {
				const Descriptor *submessage = message->nested_type(j);
				GenerateMessage(file,submessage,generator_context);
			}
		}
		for (int i=0; i<file->enum_type_count(); i++) {
			const EnumDescriptor *type = file->enum_type(i);
			GenerateEnum(type,generator_context);
		}
		return true;
	}
void GenerateSettersDec(const Descriptor *message, io::Printer *printer) const {
	for (int j=0; j<message->field_count(); j++) {
		const FieldDescriptor *field = message->field(j);
		if ((field->label() == FieldDescriptor::LABEL_REPEATED) && (field->type() == FieldDescriptor::TYPE_MESSAGE)) continue;
		const string type = getDelphiType(field);
		
		if (!type.empty()) {
			printer->Print("    procedure Set$name$(const AValue: $type$);\n","name",PropertyName(field),"type",type);
		}
	}
}
void GenerateSettersImpl(const Descriptor *message, io::Printer *printer) const {
	string writter;
	map<string,string> vars;
	for (int j=0; j<message->field_count(); j++) {
		const FieldDescriptor *field = message->field(j);
		if ((field->label() == FieldDescriptor::LABEL_REPEATED) && (field->type() == FieldDescriptor::TYPE_MESSAGE)) continue;
		const string type = getDelphiType(field);
		if (type.empty()) continue;
		vars["type"] = type;
		vars["name"] = PropertyName(field);
		vars["message"] = message->name();
		vars["pname"] = PrivateFieldName(field);
		vars["enum"] = EnumName(field);
		writter = "";
		if (typeinfo[field->type()]) writter = typeinfo[field->type()]->writter;
		else if (field->type() == FieldDescriptor::TYPE_ENUM) writter = "writeInt32";
		else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
			writter = "writeMessage";
		}
		
		if (field->type() == FieldDescriptor::TYPE_ENUM) {
			vars["input"] = "Integer(AValue)";
		} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
			if (field->label() == FieldDescriptor::LABEL_REPEATED) {
				vars["input"] = "AValue[C1].ProtobufOutput";
			} else {
				vars["input"] = "AValue.ProtobufOutput";
			}
		//} else if (field->type() == FieldDescriptor::TYPE_STRING) {
		//	vars["input"] = "AnsiString(AValue)"; // FIXME
		} else {
			if (field->label() == FieldDescriptor::LABEL_REPEATED) {
				vars["input"] = "AValue[C1]";
			} else {
				vars["input"] = "AValue";
			}
		}
		if (!writter.empty()) {
			vars["writter"] = writter;
			if (field->label() == FieldDescriptor::LABEL_REPEATED) {
				printer->Print(vars,
					"procedure TPB_$message$.Set$name$(const AValue: $type$);\n"
					"var\n"
					"  C1: Integer;\n"
					"begin\n"
					"  $pname$ := AValue;\n"
					"  for C1 := 0 to Length($pname$) - 1 do\n"
					"    ProtobufOutput.$writter$($enum$, $input$);\n"
					"end;\n\n");
			} else {
				printer->Print(vars,
					"procedure TPB_$message$.Set$name$(const AValue: $type$);\n"
					"begin\n"
					"  $pname$ := AValue;\n"
					"  ProtobufOutput.$writter$($enum$, $input$);\n"
					"end;\n\n");
			}
		}
	}
}
	void GenerateMessage(const FileDescriptor* file, const Descriptor *message, GeneratorContext* generator_context) const {
			scoped_ptr<io::ZeroCopyOutputStream> output(generator_context->Open("uPB_" + message->name() + ".pas"));
			io::Printer printer(output.get(), '$');
			printer.Print(
				"// Generated by the protocol buffer compiler.  DO NOT EDIT!\n"
				"// source: $filename$\n"
				"\n",
				"filename",file->name()
				);
			printer.Print(
				"unit uPB_$name$;\n"
				"\n"
				"interface\n"
				"\n"
				"uses\n"
				"  Classes, SysUtils, {$$IFNDEF FPC}System.Generics.Collections{$$ELSE}Contnrs{$$ENDIF}, pbOutput, uProtobufBaseObject, uProtobufReader","name",message->name());
			if (message->field_count() > 0) {
				string *types = new string[message->field_count()];
				int size = 0;
				for (int j=0; j<message->field_count(); j++) {
					const FieldDescriptor *field = message->field(j);
					if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
						const Descriptor *subtype = field->message_type();
						string type = subtype->name();
						bool addit = true;
						for (int x=0; x<size; x++) {
							if (types[x] == type) addit = false;
						}
						if (addit) {
							types[size] = type;
							size++;
						}
					}
				}
				for (int j=0; j<size; j++) {
					printer.Print(",uPB_$name$","name",types[j]);
				}
				delete[] types;
			}
			printer.Print(";\n"
				"\n"
				"type\n");

			for (int j=0; j < message->enum_type_count(); j++) {
				const EnumDescriptor *enum_type = message->enum_type(j);
				printer.Print(
					"  T$name$ = ("
					,"name",enum_type->name());
				bool tick = false;
				for (int k=0; k<enum_type->value_count(); k++) {
					if (tick) printer.Print(",");
					tick = true;
					const EnumValueDescriptor *value = enum_type->value(k);
					//cerr << value->name() << " = " << value->number() << "\n";
					char hack[10];
					snprintf(hack,9,"%d",value->number());
					printer.Print("$name$ = $hack$","name",value->name(),"hack",hack);
				}
				printer.Print(
					");\n");
			}

			printer.Print(
				"  TPB_$name$ = class(TProtobufBaseObject)\n"
				"  private\n"
				"    const\n",
				"name",message->name());
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				char hack[10];
				snprintf(hack,9,"%d",field->number());
				string name = field->name();
				UpperString(&name);
				printer.Print("      $name$ = $id$;\n","name",EnumName(field),"id",hack);
			}
			printer.Print(
				"\n"
				"    var\n");
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				const string type = getDelphiType(field);
				if (field->type() == FieldDescriptor::TYPE_BYTES) {
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"      $name$: TArray<TBytes>;\n"
							,"name",PrivateFieldName(field));
					} else {
						printer.Print(
							"      $name$: TBytes;\n"
//							"      F$name$_size: Integer;\n"
							,"name",PrivateFieldName(field));
					}
				} else if (!type.empty()) {
					printer.Print("      $name$: $type$;\n","name",PrivateFieldName(field),"type",type);
				} else if (field->type() == FieldDescriptor::TYPE_ENUM) {
					if (field->label() == FieldDescriptor::LABEL_REQUIRED) {
						const EnumDescriptor *type = field->enum_type();
						printer.Print(
							"      $name$: T$subname$;\n"
							,"name",PrivateFieldName(field)
							,"subname",type->name());
					}
				}
			}
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				if (field->type() == FieldDescriptor::TYPE_BYTES) {
					if (field->label() == FieldDescriptor::LABEL_REQUIRED) {
//						printer.Print(
//							"      function Get$name$_hex: String;\n"
//							"      function Get$name$_base64: String;\n"
//							,"name",field->camelcase_name());
					}
				}
			}
			printer.Print("\n");
			GenerateSettersDec(message,&printer);
			printer.Print(
//				"    procedure Read(const AStream: TStream);\n"
//				"    procedure Write: TProtoBufOutput;\n"
				"  public\n"
//				"    constructor Create("
				);
//			CreateArguments(&printer,message);
			printer.Print(
//				"); overload;\n"
				"    destructor Destroy; override;\n"
				"    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;\n"
				"\n");
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				map<string,string> vars;
				vars["pname"] = PrivateFieldName(field);
				vars["name"] = PropertyName(field);
				string type = getDelphiType(field);
				/*if (field->type() == FieldDescriptor::TYPE_BYTES) {
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(vars,"    property $name$: TArray<TBytes> read $pname$;\n");
					} else {
						printer.Print(
							"    property $name$: TBytes read $pname$ write Set$name$;\n"
//							"    property $name$_base64: String read Get$name$_base64;\n"
							,"name",PropertyName(field)
							,"pname",PrivateFieldName(field));
					}
				} else*/ if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					const Descriptor *subtype = field->message_type();
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						vars["subname"] = subtype->name();
						vars["type"] = getDelphiType(field);
						printer.Print(vars,"    property $name$: $type$ read $pname$ write $pname$;\n");
					} else {
						printer.Print(
							"    property $name$: TPB_$subname$ read $pname$ write Set$name$;\n"
							,"name",PropertyName(field)
							,"pname",PrivateFieldName(field)
							,"subname",subtype->name());
					}
				} else if (!type.empty()) {
					vars["type"] = type;
					printer.Print(vars,"    property $name$: $type$ read $pname$ write Set$name$;\n");
				}
			}
			printer.Print(
				"  end;\n"
				"\n"
				"implementation\n"
				"\n"
				"uses\n"
				"  pbPublic, uCommon;\n"
				"\n"
				"\n"
//				"constructor TPB_$name$.Create("
				,"name",message->name());
/*			CreateArguments(&printer,message);
			printer.Print(");\nbegin\n");
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				if (field->type() == FieldDescriptor::TYPE_BYTES) {
					if (field->label() != FieldDescriptor::LABEL_REPEATED) {
						printer.Print("  F$name$ := A$name$;\n","name",PrivateFieldName(field));
					}
				} else if (field->type() == FieldDescriptor::TYPE_INT32) {
					if (field->label() != FieldDescriptor::LABEL_REPEATED) {
						printer.Print("  F$name$ := A$name$;\n","name",PrivateFieldName(field));
					}
				} else if (field->type() == FieldDescriptor::TYPE_STRING) {
					if (field->label() != FieldDescriptor::LABEL_REPEATED) {
						printer.Print("  F$name$ := A$name$;\n","name",PrivateFieldName(field));
					}
				} else if (field->type() == FieldDescriptor::TYPE_BOOL) {
					if (field->label() != FieldDescriptor::LABEL_REPEATED) {
						printer.Print("  F$name$ := A$name$;\n","name",PrivateFieldName(field));
					}
				}
			}*/
			printer.Print(
//				"end;\n"
//				"{ TPBR_$name$ }\n"
				"destructor TPB_$name$.Destroy;\n"
				"begin\n"
				,"name",message->name());
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					if (field->label() == FieldDescriptor::LABEL_REQUIRED) {
						printer.Print("  if Assigned($name$) then $name$.Free;\n","name",PrivateFieldName(field));
					} else if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print("  if Assigned($name$) then\n    $name$.Free;\n","name",PrivateFieldName(field));
					} else if (field->label() == FieldDescriptor::LABEL_OPTIONAL) {
						printer.Print("  if Assigned($name$) then $name$.Free;\n","name",PrivateFieldName(field));
					}
				}
			}
			printer.Print(
				"  inherited;\n"
				"end;\n"
				"procedure TPB_$name$.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);\n"
				"var\n"
				"  tag,field_number,wire_type,endpos : Integer;\n"
				"begin\n",
				"name",message->name());
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"  if not Assigned($pname$) then\n"
							"    $pname$ := $subname$.Create;\n"
							"\n"
							,"pname",PrivateFieldName(field)
							,"subname",getDelphiType(field));
					}
				}
			}
			printer.Print(
				"  endpos := AProtobufReader.getPos + ASize;\n"
				"  while (AProtobufReader.getPos < endpos) and\n"
				"        (AProtobufReader.GetNext(tag, wire_type, field_number)) do begin\n"
				"    case field_number of\n");
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				string name = field->name();
				UpperString(&name);
				map<string,string> vars;
				vars["name"] = EnumName(field);
				vars["pname"] = PrivateFieldName(field);
				if (field->type() == FieldDescriptor::TYPE_INT32) {
					if (field->is_packed()) {
						printer.Print(
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
							"        // FIXME $pname$ := AProtobufReader.readInt32;\n"
							"        AProtobufReader.skipField(tag);\n"
							"      end;\n","name",EnumName(field)
							,"pname",PrivateFieldName(field));
					} else if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_VARINT);\n"
							"        SetLength($pname$, Length($pname$) + 1);\n"
							"        $pname$[Length($pname$)-1] := AProtobufReader.readInt32;\n"
							"      end;\n","name",EnumName(field)
							,"pname",PrivateFieldName(field));
					} else {
						printer.Print(
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_VARINT);\n"
							"        $pname$ := AProtobufReader.readInt32;\n"
							"      end;\n","name",EnumName(field)
							,"pname",PrivateFieldName(field));
					}
				} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					const Descriptor *subtype = field->message_type(); 
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
							"        $pname$.Add(TPB_$subname$.Create(AProtobufReader,AProtobufReader.readInt32));\n"
							"      end;\n"
							,"name",EnumName(field)
							,"pname",PrivateFieldName(field)
							,"subname",subtype->name());
					} else {
						printer.Print(
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
							"        if not Assigned($pname$) then\n"
							"          $pname$ := TPB_$subname$.Create;\n"
							"        $pname$.LoadFromProtobufReader(AProtobufReader,AProtobufReader.readInt32);\n"
							"      end;\n"
							,"name",EnumName(field)
							,"pname",PrivateFieldName(field)
							,"subname",subtype->name());
					}
				} else if (field->type() == FieldDescriptor::TYPE_ENUM) {
					if (field->label() != FieldDescriptor::LABEL_REPEATED) {
						const EnumDescriptor *type = field->enum_type();
						printer.Print(
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_VARINT);\n"
							"        $pname$ := T$subname$(AProtobufReader.readEnum);\n"
							"      end;\n"
							,"name",EnumName(field)
							,"pname",PrivateFieldName(field)
							,"subname",type->name());
					}
				} else if (field->type() == FieldDescriptor::TYPE_BOOL) {
					if (field->label() != FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_VARINT);\n"
							"        $pname$ := AProtobufReader.readBoolean;\n"
							"      end;\n"
							,"name",EnumName(field)
							,"pname",PrivateFieldName(field));
					}
				} else {
					string type = getDelphiType(field);
					if (!type.empty()) {
						vars["reader"] = typeinfo[field->type()]->reader;
						vars["wiretype"] = typeinfo[field->type()]->wiretype;
						if (field->label() == FieldDescriptor::LABEL_REPEATED) {
							if (field->type() == FieldDescriptor::TYPE_BYTES) {
								printer.Print(vars,
									"      $name$: begin\n"
									"        Assert(wire_type = $wiretype$);\n"
									"        SetLength($pname$, Length($pname$) + 1);\n"
									"        AProtobufReader.$reader$($pname$[Length($pname$)-1]);\n"
									"      end;\n");
							} else {
								printer.Print(vars,
									"      $name$: begin\n"
									"        Assert(wire_type = $wiretype$);\n"
									"        SetLength($pname$, Length($pname$) + 1);\n"
									"        $pname$[Length($pname$)-1] := AProtobufReader.$reader$;\n"
									"      end;\n");
							}
						} else {
							if (field->type() == FieldDescriptor::TYPE_BYTES) {
								printer.Print(vars,
									"      $name$: begin\n"
									"        Assert(wire_type = $wiretype$);\n"
									"        AProtobufReader.$reader$($pname$);\n"
									"      end;\n");
							} else {
								printer.Print(vars,
									"      $name$: begin\n"
									"        Assert(wire_type = $wiretype$);\n"
									"        $pname$ := AProtobufReader.$reader$;\n"
									"      end;\n");
							}
						}
					}
				}
			}
			printer.Print(
				"    else\n"
				"      AProtobufReader.skipField(tag);\n"
				"    end;\n"
//				"    tag := AProtobufReader.readTag;\n"
				"  end;\n"
				"end;\n");
			/*FIXME for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				string name = field->name();
				UpperString(&name);
				if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					//const Descriptor *subtype = field->message_type();
					if (field->label() == FieldDescriptor::LABEL_OPTIONAL) {
						printer.Print(
							"  if Assigned(F$pname$) then\n"
							"  begin\n"
							"    pbmsg := F$pname$.GetProtobuf;\n"
							"    try\n"
							"      pboutput.writeMessage($name$,pbmsg);\n"
							"    finally\n"
							"      pbmsg.Free;\n"
							"    end;\n"
							"  end;\n"
							,"name",EnumName(field)
							,"pname",PrivateFieldName(field));
					}
				}
			}*/
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				if (field->type() == FieldDescriptor::TYPE_BYTES) {
					if (field->label() == FieldDescriptor::LABEL_REQUIRED) {
//						printer.Print(
//							"function TPB_$name$.Get$type$_hex: String;\n"
//							"var\n"
//							"  C1 : Integer;\n"
//							"begin\n"
//							"  result := '';\n"
//							"  for C1 := 0 to F$type$_size - 1 do\n"
//							"    result := result + IntToHex(F$type$_bytes[C1],2);\n"
//							"  result := LowerCase(result);\n"
//							"end;\n"
//							"function TPB_$name$.Get$type$_base64: String;\n"
//							"begin\n"
//							"  result := EncodeBase64(F$type$_bytes,F$type$_size)\n"
//							"end;\n"
//							,"name",message->name()
//							,"type",field->camelcase_name()
//						);
					}
				}
			}
			GenerateSettersImpl(message,&printer);
			printer.Print(
				"end.\n");
	}
	virtual const string getDelphiType(const FieldDescriptor *field) const = 0;
};
class PascalGenerator : public BaseGenerator {
	const string getDelphiType(const FieldDescriptor *field) const {
		string out;
		if (typeinfo[field->type()]) out = typeinfo[field->type()]->delphiName;
		else if (field->type() == FieldDescriptor::TYPE_ENUM) {
			const EnumDescriptor *type = field->enum_type();
			out = string("T")+type->name();
		} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
			const Descriptor *subtype = field->message_type();
			if (field->label() == FieldDescriptor::LABEL_REPEATED) {
				return "array of TPB_"+subtype->name();
			} else {
				return "TPB_"+subtype->name();
			}
		} else return "";
		if (field->label() == FieldDescriptor::LABEL_REPEATED) {
			return "array of "+out;
		} else return out;
	}
};
class DelphiGenerator : public BaseGenerator {
const string getDelphiType(const FieldDescriptor *field) const {
	string out;
	if (typeinfo[field->type()]) out = typeinfo[field->type()]->delphiName;
	else if (field->type() == FieldDescriptor::TYPE_ENUM) {
		const EnumDescriptor *type = field->enum_type();
		out = string("T")+type->name();
	} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
		const Descriptor *subtype = field->message_type();
		if (field->label() == FieldDescriptor::LABEL_REPEATED) {
			return "TObjectList<TPB_"+subtype->name()+">";
		} else {
			return "TPB_"+subtype->name();
		}
	} else return "";
	if (field->label() == FieldDescriptor::LABEL_REPEATED) {
		return "TArray<"+out+">";
	} else return out;
}
};
struct typeInfo* makeType(string type, string writter, string reader, string wiretype) {
	struct typeInfo *t = new struct typeInfo;
	t->delphiName = type;
	t->writter = writter;
	t->reader = reader;
	t->	wiretype = wiretype;
	return t;
}
int main(int argc, char *argv[]) {
	typeinfo[FieldDescriptor::TYPE_INT32] = makeType("Integer","writeInt32","FIXME","WIRETYPE_VARINT");
	typeinfo[FieldDescriptor::TYPE_UINT32] = makeType("UINT32","writeUInt32","readUInt32","WIRETYPE_VARINT");
	typeinfo[FieldDescriptor::TYPE_STRING] = makeType("String","writeString","readUtf8String","WIRETYPE_LENGTH_DELIMITED");
	typeinfo[FieldDescriptor::TYPE_BOOL] = makeType("Boolean","writeBoolean","FIXME","WIRETYPE_VARINT");
	typeinfo[FieldDescriptor::TYPE_BYTES] = makeType("TBytes","writeBytes","readBytes","WIRETYPE_LENGTH_DELIMITED");
	cerr << "self " << argv[0] << " " << argc << "\n";
	BaseGenerator *gen;
	if (strcmp("protoc-gen-pascal",argv[0]) == 0) gen = new PascalGenerator();
	else gen = new DelphiGenerator();
	int ret = google::protobuf::compiler::PluginMain(argc,argv,gen);
	delete gen;
	return ret;
}
