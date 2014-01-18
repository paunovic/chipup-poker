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
	return out;
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
	cerr << name << "\n";
	printer.Print(
		"unit u$name$;\n"
		"\n"
		"interface\n"
		"\n"
		"const\n"
		,"name",type->name());
	for (int j=0; j<type->value_count(); j++) {
		const EnumValueDescriptor *value = type->value(j);
		//cerr << value->name() << " = " << value->number() << "\n";
		char hack[10];
		snprintf(hack,9,"%d",value->number());
		printer.Print("  $name$ = $hack$;\n","name",value->name(),"hack",hack);
	}
	printer.Print(
		"\n"
		"implementation\n"
		"\n"
		"end.");
}
string EnumName(const FieldDescriptor *field) {
	string name = field->name();
	UpperString(&name);
	return "FN_"+name;
}
const string getDelphiType(const FieldDescriptor *field) {
	if (typeinfo[field->type()]) return typeinfo[field->type()]->delphiName;
	else if (field->type() == FieldDescriptor::TYPE_ENUM) {
		const EnumDescriptor *type = field->enum_type();
		return string("T")+type->name();
	} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
		const Descriptor *subtype = field->message_type();
		if (field->label() == FieldDescriptor::LABEL_REPEATED) {
			return "TPB_"+subtype->name()+"s";
		} else {
			return "TPB_"+subtype->name();
		}
	}
	return "";
}
void GenerateSettersDec(const Descriptor *message, io::Printer *printer) {
	cerr << "dec\n";
	for (int j=0; j<message->field_count(); j++) {
		const FieldDescriptor *field = message->field(j);
		if (field->label() == FieldDescriptor::LABEL_REPEATED) continue;
		cerr << field->name() << "\n";
		const string type = getDelphiType(field);
		
		if (!type.empty()) {
			cerr << field->name() << " " << type << " int\n";
			printer->Print("    procedure Set$name$(const AValue: $type$);\n","name",PropertyName(field),"type",type);
		}
	}
}
void GenerateSettersImpl(const Descriptor *message, io::Printer *printer) {
	string writter;
	cerr << "impl\n";
	map<string,string> vars;
	for (int j=0; j<message->field_count(); j++) {
		const FieldDescriptor *field = message->field(j);
		if (field->label() == FieldDescriptor::LABEL_REPEATED) continue;
		cerr << field->name() << "\n";
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
			vars["input"] = "AValue.ProtobufOutput";
		//} else if (field->type() == FieldDescriptor::TYPE_STRING) {
		//	vars["input"] = "AnsiString(AValue)"; // FIXME
		} else {
			vars["input"] = "AValue";
		}
		if (!writter.empty()) {
			vars["writter"] = writter;
			printer->Print(vars,
				"procedure TPB_$message$.Set$name$(const AValue: $type$);\n"
				"begin\n"
				"  F$pname$ := AValue;\n"
				"  ProtobufOutput.$writter$($enum$, $input$);\n"
				"end;\n\n");
		}
	}
}
// some code based on http://sourceforge.net/p/protobuf-delphi/wiki/Example/
class DelphiGenerator : public CodeGenerator {
	bool Generate(const FileDescriptor* file, const string& parameter, GeneratorContext* generator_context, string* error) const {
		cerr << file->name() << "\n";

		for (int i=0; i<file->message_type_count(); i++) {
			const Descriptor *message = file->message_type(i);
			cerr << "message#" << i << " " << message->name() << "\n";
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
				"interface\n"
				"uses\n"
				"  WinApi.Windows, System.Classes, System.SysUtils, System.Generics.Collections, pbOutput, uProtobufBaseObject, uProtobufReader","name",message->name());
			if (message->field_count() > 0) {
				string *types = new string[message->field_count()];
				cerr << "field count " << message->field_count() << "\n";
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
					printer.Print("ce$name$ = $hack$","name",value->name(),"hack",hack);
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
				printer.Print("      FN_$name$ = $id$;\n","name",name,"id",hack);
			}
			printer.Print(
				"    var\n");
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				const string type = getDelphiType(field);
				if (field->type() == FieldDescriptor::TYPE_BYTES) {
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"      F$name$: TArray<TBytes>;\n"
							,"name",PrivateFieldName(field));
					} else {
						printer.Print(
							"      F$name$: TBytes;\n"
//							"      F$name$_size: Integer;\n"
							,"name",PrivateFieldName(field));
					}
				} else if (!type.empty()) {
					printer.Print("      F$name$: $type$;\n","name",PrivateFieldName(field),"type",type);
				} else if (field->type() == FieldDescriptor::TYPE_ENUM) {
					if (field->label() == FieldDescriptor::LABEL_REQUIRED) {
						const EnumDescriptor *type = field->enum_type();
						printer.Print(
							"      F$name$: T$subname$;\n"
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
				if (field->type() == FieldDescriptor::TYPE_INT32) {
					printer.Print("    property $name$: Integer read F$name$ write Set$name$;\n","name",PropertyName(field));
				} else if (field->type() == FieldDescriptor::TYPE_STRING) {
					printer.Print("    property $name$: String read F$name$ write Set$name$;\n","name",PropertyName(field));
				} else if (field->type() == FieldDescriptor::TYPE_BOOL) {
					printer.Print("    property $name$: Boolean read F$name$ write Set$name$;\n","name",PropertyName(field));
				} else if (field->type() == FieldDescriptor::TYPE_BYTES) {
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"    property $name$: TArray<TBytes> read F$name$;\n"
							,"name",PropertyName(field));
					} else {
						printer.Print(
							"    property $name$: TBytes read F$pname$ write Set$name$;\n"
//							"    property $name$_base64: String read Get$name$_base64;\n"
							,"name",PropertyName(field)
							,"pname",PrivateFieldName(field));
					}
				} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					const Descriptor *subtype = field->message_type();
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"    property $name$: TPB_$subname$s read F$name$;\n"
							,"name",PropertyName(field),"subname",subtype->name());
					} else {
						printer.Print(
							"    property $name$: TPB_$subname$ read F$name$ write Set$name$;\n"
							,"name",PropertyName(field)
							,"subname",subtype->name());
					}
				} else if (field->type() == FieldDescriptor::TYPE_ENUM) {
					if (field->label() == FieldDescriptor::LABEL_REQUIRED) {
						const EnumDescriptor *type = field->enum_type();
						printer.Print("    property $name$: T$subname$ read F$pname$ write Set$pname$;\n"
							,"name",PropertyName(field)
							,"subname",type->name()
							,"pname",PrivateFieldName(field));
					}
				}
			}
			printer.Print(
				"  end;\n"
				"\n"
				"  TPB_$name$s = TObjectList<TPB_$name$>;\n"
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
						printer.Print("  if Assigned(F$name$) then F$name$.Free;\n","name",field->camelcase_name());
					} else if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print("  F$name$.Free;\n","name",field->camelcase_name());
					} else if (field->label() == FieldDescriptor::LABEL_OPTIONAL) {
						printer.Print("  if Assigned(F$name$) then F$name$.Free;\n","name",field->camelcase_name());
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
						const Descriptor *subtype = field->message_type();
						printer.Print(
							"  if not Assigned(F$pname$) then\n"
							"    F$pname$ := TPB_$subname$s.Create;\n"
							"\n"
							,"pname",PrivateFieldName(field)
							,"subname",subtype->name());
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
				if (field->type() == FieldDescriptor::TYPE_INT32) {
					printer.Print(
						"      FN_$name$:\n"
						"        begin\n"
						"          Assert(wire_type = WIRETYPE_VARINT);\n"
						"          F$pname$ := AProtobufReader.readInt32;\n"
						"        end;\n","name",name
						,"pname",PrivateFieldName(field));
				} else if (field->type() == FieldDescriptor::TYPE_STRING) {
					printer.Print(
						"      FN_$name$:\n"
						"        begin\n"
						"          Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
						"          F$pname$ := String(AProtobufReader.readUtf8String);\n"
						"        end;\n"
						,"pname",PrivateFieldName(field)
						,"name",name);
				} else if (field->type() == FieldDescriptor::TYPE_BYTES) {
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
						"      FN_$name$:\n"
						"        begin\n"
						"          Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
						"          SetLength(F$pname$, Length(F$pname$) + 1);\n"
						"          AProtobufReader.readBytes(F$pname$[Length(F$pname$)-1]);\n"
						"        end;\n"
						,"name",name
						,"pname",PrivateFieldName(field));
					} else {
						printer.Print(
						"      FN_$name$:\n"
						"        begin\n"
						"          Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
						"          AprotobufReader.readBytes(F$pname$);\n"
						"        end;\n"
						,"name",name
						,"pname",PrivateFieldName(field));
					}
				} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					const Descriptor *subtype = field->message_type(); 
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"        FN_$name$:\n"
							"          begin\n"
							"            Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
							"            F$pname$.Add(TPB_$subname$.Create(AProtobufReader,AProtobufReader.readInt32));\n"
							"          end;\n"
							,"name",name
							,"pname",PrivateFieldName(field)
							,"subname",subtype->name());
					} else {
						printer.Print(
							"      FN_$name$:\n"
							"        begin\n"
							"          Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
							"          if not Assigned(F$name$) then\n"
							"            F$name$ := TPB_$subname$.Create;\n"
							"          F$name$.LoadFromProtobufReader(AProtobufReader,AProtobufReader.readInt32);\n"
							"        end;\n"
							,"name",name
							,"subname",subtype->name());
					}
				} else if (field->type() == FieldDescriptor::TYPE_ENUM) {
					if (field->label() == FieldDescriptor::LABEL_REQUIRED) {
						const EnumDescriptor *type = field->enum_type();
						printer.Print(
							"      FN_$name$:\n"
							"        begin\n"
							"          Assert(wire_type = WIRETYPE_VARINT);\n"
							"          F$pname$ := T$subname$(AProtobufReader.readEnum);\n"
							"        end;\n"
							,"name",name
							,"pname",PrivateFieldName(field)
							,"subname",type->name());
					}
				}
			}
			printer.Print(
				"      else\n"
				"        AProtobufReader.skipField(tag);\n"
				"    end;\n"
//				"    tag := AProtobufReader.readTag;\n"
				"  end;\n"
				"end;\n");
			for (int j=0; j<message->field_count(); j++) {
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
							"      pboutput.writeMessage(FN_$name$,pbmsg);\n"
							"    finally\n"
							"      pbmsg.Free;\n"
							"    end;\n"
							"  end;\n"
							,"name",name
							,"pname",PrivateFieldName(field));
					}
				}
			}
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
		for (int i=0; i<file->enum_type_count(); i++) {
			const EnumDescriptor *type = file->enum_type(i);
			GenerateEnum(type,generator_context);
		}
		return true;
	}
};
struct typeInfo* makeType(string type, string writter) {
	struct typeInfo *t = new struct typeInfo;
	t->delphiName = type;
	t->writter = writter;
	return t;
}
int main(int argc, char *argv[]) {
	typeinfo[FieldDescriptor::TYPE_INT32] = makeType("Integer","writeInt32");
	typeinfo[FieldDescriptor::TYPE_STRING] = makeType("String","writeString");
	typeinfo[FieldDescriptor::TYPE_BOOL] = makeType("Boolean","writeBoolean");
	typeinfo[FieldDescriptor::TYPE_BYTES] = makeType("TBytes","writeBytes");
	DelphiGenerator *gen = new DelphiGenerator();
	int ret = google::protobuf::compiler::PluginMain(argc,argv,gen);
	delete gen;
	return ret;
}
