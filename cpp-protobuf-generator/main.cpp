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

class TypeInfo {
public:
	TypeInfo(string type, string writter, string reader, string wiretype, string defaultdefault) {
		this->delphiName = type;
		baseDelphiName = type;
		this->writter = writter;
		this->reader = reader;
		this->wiretype = wiretype;
		this->defaultdefault = defaultdefault;
	}
	TypeInfo(FieldDescriptor::Type type): type(type) {
		switch (type) {
		case FieldDescriptor::TYPE_INT64:
			baseDelphiName = delphiName = "Int64";
			writter = "WriteInt64";
			reader = "readInt64";
			wiretype = "WIRETYPE_VARINT";
			defaultdefault = "0";
			break;
		case FieldDescriptor::TYPE_UINT64:
			baseDelphiName = delphiName = "UInt64";
			writter = "WriteInt64";
			reader = "readInt64";
			wiretype = "WIRETYPE_VARINT";
			defaultdefault = "0";
			break;
		case FieldDescriptor::TYPE_INT32:
			baseDelphiName = delphiName = "Integer";
			writter = "writeInt32";
			reader = "readInt32";
			wiretype = "WIRETYPE_VARINT";
			defaultdefault = "0";
			break;
		case FieldDescriptor::TYPE_BOOL:
			baseDelphiName = delphiName = "Boolean";
			writter = "writeBoolean";
			reader = "readBoolean";
			wiretype = "WIRETYPE_VARINT";
			defaultdefault = "false";
			break;
		case FieldDescriptor::TYPE_STRING:
			baseDelphiName = delphiName = "String";
			writter = "writeString";
			reader = "readUtf8String";
			wiretype = "WIRETYPE_LENGTH_DELIMITED";
			defaultdefault = "''";
			break;
		case FieldDescriptor::TYPE_MESSAGE:
			// FIXME
			defaultdefault = "nil";
			writter = "writeMessage";
			wiretype = "WIRETYPE_LENGTH_DELIMITED";
			break;
		case FieldDescriptor::TYPE_BYTES:
			baseDelphiName = delphiName = "TBytes";
			writter = "writeBytes";
			reader = "readBytes";
			wiretype = "WIRETYPE_LENGTH_DELIMITED";
			break;
		case FieldDescriptor::TYPE_UINT32:
			baseDelphiName = delphiName = "UINT32";
			writter = "writeUInt32";
			reader = "readUInt32";
			wiretype = "WIRETYPE_VARINT";
			defaultdefault = "0";
			break;
		case FieldDescriptor::TYPE_ENUM:
			// FIXME
			writter = "writeInt32";
			break;
		default:
			assert(false);
		}
	}
	string getDefault() { return defaultdefault; }
	string getWritter() { return writter; }
	string getReader() { return reader; }
	string getWireType() { return wiretype; }
	string getDelphiName() { return delphiName; }
	string getBaseDelphiName() { return baseDelphiName; }
	string PropertyName() { return propertyName; }
	string PrivateFieldName() { return privateField; }
	string getLableString() {
		switch (field->label()) {
		case FieldDescriptor::LABEL_OPTIONAL: return "optional";
		}
	}
	void printPrivateVariable(io::Printer *printer,const FieldDescriptor *field) {
		printer->Print(
			"      $pname$: $type$;\n",
			"pname",PrivateFieldName(),
			"type",delphiName);
	}
	
	TypeInfo getInstance(const FieldDescriptor *field) {
		TypeInfo copy = *this;
		copy.setupFields(field);
		if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
			copy.setType(field);
			return copy;
		} else if (field->type() == FieldDescriptor::TYPE_ENUM) {
			copy.setEnum(field);
			if (field->label() == FieldDescriptor::LABEL_REPEATED) {
				copy.delphiName = "TList<"+copy.delphiName+">";
			}
			return copy;
		}
		if (field->label() == FieldDescriptor::LABEL_REPEATED) {
			copy.delphiName = "TList<"+copy.delphiName+">";
			return copy;
		}
		return copy;
	}
private:
	void setupFields(const FieldDescriptor *field) {
		this->field = field;
		this->type = field->type();

		//cerr << "getting name for " << field->full_name() << "\n";
		if (field->name() == "_id") {
			propertyName = "MongoId";
		} else {
			string out = field->camelcase_name();
			string::iterator i = out.begin();
			if ('a' <= *i && *i <= 'z') *i += 'A' - 'a';
			propertyName = out;
		}
		
		string out = field->camelcase_name();
		string::iterator i = out.begin();
		if ('a' <= *i && *i <= 'z') *i += 'A' - 'a';
		privateField = "F"+out;
	}
	void setType(const FieldDescriptor *field) {
		const Descriptor *subtype = field->message_type();
		if (field->label() == FieldDescriptor::LABEL_REPEATED) {
			delphiName = "TList<TPB_"+subtype->name()+">";
			baseDelphiName = "TPB_"+subtype->name();
		} else {
			delphiName = "TPB_"+subtype->name();
			baseDelphiName = delphiName;
		}
	}
	void setEnum(const FieldDescriptor *field) {
		const EnumDescriptor *subtype = field->enum_type();
		delphiName = "T" + subtype->name();
		defaultdefault = delphiName+"(0)";
		baseDelphiName = delphiName;
	}
	string delphiName;
	string baseDelphiName;
	string writter;
	string reader;
	string wiretype;
	string defaultdefault,propertyName,privateField;
	const FieldDescriptor *field;
	FieldDescriptor::Type type;
};
TypeInfo *typeinfo[18];
// taken from cpp_helpers.cc in protobuf
string StripProto(const string& filename) {
	if (HasSuffixString(filename, ".protodevel")) {
		return StripSuffixString(filename, ".protodevel");
	} else {
		return StripSuffixString(filename, ".proto");
	}
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
	scoped_ptr<io::ZeroCopyOutputStream> output(generator_context->Open("Poker.Protobufs.Enum." + type->name() + ".pas"));
	io::Printer printer(output.get(), '$');
	printer.Print(
		"unit Poker.Protobufs.Enum.$name$;\n"
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
	string name = field->camelcase_name();
	string::iterator i = name.begin();
	if ('a' <= *i && *i <= 'z') *i += 'A' - 'a';
	return "k"+name+"FieldNumber";
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
		TypeInfo instance = typeinfo[field->type()]->getInstance(field);

		printer->Print(
				"    procedure set_has_$name$;\n"
				"    procedure clear_has_$name$;\n"
				,"name",instance.PropertyName());
		if (field->label() == FieldDescriptor::LABEL_REPEATED) continue;
		const string type = instance.getDelphiName();
		
		if (!type.empty()) {
			printer->Print(
				"    procedure Set$name$(const AValue: $type$);\n"
				,"name",instance.PropertyName(),"type",type);
		}
	}
}
void GenerateSettersImpl(const Descriptor *message, io::Printer *printer) const {
	string writter;
	map<string,string> vars;
	char hack[10];
	for (int j=0; j<message->field_count(); j++) {
		const FieldDescriptor *field = message->field(j);
		if (!typeinfo[field->type()]) cerr << "cant get new type for " << field->name() << field->type() << endl;
		assert(typeinfo[field->type()]);
		TypeInfo thisType = typeinfo[field->type()]->getInstance(field);
		const string type = thisType.getDelphiName();
		assert(field->number() < 30);
		snprintf(hack,10,"%d",1 << (field->number()-1));
		vars["bit"] = hack;
		vars["message"] = message->name();
		vars["name"] = thisType.PropertyName();
		vars["pname"] = thisType.PrivateFieldName();
		if (type.empty()) {
			cerr << "cant find type into for field " << field->name() << endl;
			continue;
		}
		if ((field->type() == FieldDescriptor::TYPE_BYTES) && (field->label() != FieldDescriptor::LABEL_REPEATED)) {
			printer->Print(vars,
			"procedure TPB_$message$.clear_$name$;\n"
			"begin\n"
			"  SetLength($pname$,0);\n"
			"  clear_has_$name$;\n"
			"end;\n\n"
			);
		} else if (/*(field->type() == FieldDescriptor::TYPE_MESSAGE) &&*/ (field->label() == FieldDescriptor::LABEL_REPEATED)) {
			printer->Print(vars,
			"procedure TPB_$message$.clear_$name$;\n"
			"begin\n"
			"  $pname$.Clear;\n"
			"  clear_has_$name$;\n"
			"end;\n\n"
			);
		} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
			printer->Print(vars,
			"procedure TPB_$message$.clear_$name$;\n"
			"begin\n"
			"  FreeAndNil($pname$);\n" // FIXME?
			"  clear_has_$name$;\n"
			"end;\n\n"
			);
		} else if (typeinfo[field->type()]) {
			vars["default"] = thisType.getDefault();
			printer->Print(vars,
			"procedure TPB_$message$.clear_$name$;\n"
			"begin\n"
			"  $pname$ := $default$;\n"
			"  clear_has_$name$;\n"
			"end;\n\n"
			);
		} else {
			cerr << "cant get new type for " << field->name() << endl;
		}
		printer->Print(vars,
			"function TPB_$message$.has_$name$: Boolean;\n"
			"begin\n"
			"  Result := (_has_bits_ and $bit$) > 0;\n"
			"end;\n\n"
			"procedure TPB_$message$.set_has_$name$;\n"
			"begin\n"
			"  _has_bits_ := _has_bits_ or $bit$;\n"
			"end;\n\n"
			"procedure TPB_$message$.clear_has_$name$;\n"
			"begin\n"
			"  _has_bits_ := _has_bits_ xor $bit$;\n"
			"end;\n\n"
			);

		vars["enum"] = EnumName(field);

		if (field->label() == FieldDescriptor::LABEL_REPEATED) {
			TypeInfo instance = typeinfo[field->type()]->getInstance(field);
			vars["subtype"] = instance.getBaseDelphiName();
			vars["tagtype"] = instance.getWireType();
			if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
			} else {
				cerr << "cant hook" << instance.getBaseDelphiName() << endl;
			}
			printer->Print(vars,
				"procedure TPB_$message$.$name$NotifyEvent(Sender: TObject; const Item: $subtype$; Action: TCollectionNotification);\n"
				"begin\n"
				"  Assert(Action = cnAdded);\n");
			if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
				printer->Print(vars,
					"  ProtobufOutput.writeTag($enum$,$tagtype$);\n"
					"  ProtobufOutput.writeRawVarint32(Item.ProtobufOutput.getSerializedSize);\n"
					"  Item.ProtobufOutput.writeTo(ProtobufOutput);\n");
			} else if ((field->type() == FieldDescriptor::TYPE_INT32) || (field->type() == FieldDescriptor::TYPE_UINT32)) {
				vars["writter"] = instance.getWritter();
				printer->Print(vars,
					"  ProtobufOutput.$writter$($enum$,Item);\n");
			}
			printer->Print(
				"end;\n"
				"\n"
				);
			continue;
		}
		vars["type"] = type;
		writter = "";
		writter = thisType.getWritter();
		
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
					"procedure TPB_$message$.Set$name$(const AValue: $type$); // FIXME, expose the TList and use a hook?\n"
					"var\n"
					"  C1: Integer;\n"
					"begin\n"
					"  for C1 := 0 to AValue.Count - 1 do\n"
					"    $pname$.Add(AValue[C1]);\n"
					"  for C1 := 0 to $pname$.Count - 1 do\n"
					"    ProtobufOutput.$writter$($enum$, $input$);\n"
					"end;\n\n");
			} else if (field->type() == FieldDescriptor::TYPE_BYTES) {
				printer->Print(vars,
					"procedure TPB_$message$.Set$name$(const AValue: $type$);\n"
					"var\n"
					"  C1: Integer;\n"
					"begin\n"
					"  SetLength($pname$,Length(AValue));\n"
					"  for C1 := 0 to Length(AValue) - 1 do\n"
					"    $pname$[C1] := AValue[C1];\n"
					"  ProtobufOutput.$writter$($enum$, $input$);\n"
					"end;\n\n");
			} else {
				printer->Print(vars,
					"procedure TPB_$message$.Set$name$(const AValue: $type$);\n"
					"begin\n"
					"  $pname$ := AValue;\n"
					"  ProtobufOutput.$writter$($enum$, $input$);\n" // FIXME
					"  set_has_$name$;\n"
					"end;\n\n");
			}
		}
	}
}
	void GenerateMessage(const FileDescriptor* file, const Descriptor *message, GeneratorContext* generator_context) const {
		char hack[10];
		bool needsInit = false;
		map<string,string> vars;

			scoped_ptr<io::ZeroCopyOutputStream> output(generator_context->Open("Poker.Protobufs.Objects." + message->name() + ".pas"));
			io::Printer printer(output.get(), '$');
			printer.Print(
				"// Generated by the protocol buffer compiler.  DO NOT EDIT!\n"
				"// source: $filename$\n"
				"\n"
				"unit Poker.Protobufs.Objects.$name$;\n"
				"\n"
				"interface\n"
				"\n"
				"uses\n"
				"  Classes, SysUtils, {$$IFNDEF FPC}System.Generics.Collections{$$ELSE}Contnrs{$$ENDIF}, pbOutput, Poker.Protobufs.Objects.Base, Poker.Protobufs.Reader"
				,"filename",file->name()
				,"name",message->name());
			if (message->field_count() > 0) {
				string *types = new string[message->field_count()];
				int size = 0;
				for (int j=0; j<message->field_count(); j++) {
					const FieldDescriptor *field = message->field(j);
					
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						needsInit = true;
					}
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
					} else if (field->type() == FieldDescriptor::TYPE_ENUM) {
						const EnumDescriptor *type = field->enum_type();
						const Descriptor *parent = type->containing_type();
						if (parent == NULL) {
						} else if (parent != message) {
							string type = parent->name();
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
				}
				for (int j=0; j<size; j++) {
					printer.Print(",Poker.Protobufs.Objects.$name$","name",types[j]);
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
					snprintf(hack,9,"%d",value->number());
					printer.Print("$name$ = $hack$","name",value->name(),"hack",hack);
				}
				printer.Print(");\n");
			}

			printer.Print(
				"  TPB_$name$ = class(TProtobufBaseObject)\n"
				"  private\n"
				"    const\n",
				"name",message->name());
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				snprintf(hack,9,"%d",field->number());
				printer.Print("      $name$ = $id$;\n","name",EnumName(field),"id",hack);
			}
			printer.Print(
				"\n"
				"    var\n");
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				if (!typeinfo[field->type()]) cerr << "cant get new type for " << field->name() << field->type() << endl;
				assert(typeinfo[field->type()]);
				TypeInfo instance = typeinfo[field->type()]->getInstance(field);
				string type = instance.getDelphiName();
				instance.printPrivateVariable(&printer,field);
			}
			printer.Print(
				"      _has_bits_: Integer;\n"
				"\n");
			GenerateSettersDec(message,&printer);
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				if (field->label() == FieldDescriptor::LABEL_REPEATED) {
					TypeInfo instance = typeinfo[field->type()]->getInstance(field);
					printer.Print(
						"    procedure $name$NotifyEvent(Sender: TObject; const Item: $subname$; Action: TCollectionNotification);\n"
						,"name",instance.PropertyName()
						,"pname",instance.PrivateFieldName()
						,"subname",instance.getBaseDelphiName());
				}
			}
			if (needsInit) {
				printer.Print(
					"\n"
					"  protected\n"
					"    procedure InitObjects; override;\n"
					"    procedure HookNotifiers; override;\n");
			}
			printer.Print("\n"
				"  public\n"
				);
			printer.Print(
				"    constructor Create(const AFrom: TPB_$name$); overload;\n"
				"    destructor Destroy; override;\n"
				"    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;\n"
				"    procedure MergeFrom(const from: TPB_$name$);\n"
				"\n",
				"name",message->name());
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				TypeInfo instance = typeinfo[field->type()]->getInstance(field);

				vars["pname"] = instance.PrivateFieldName();
				vars["name"] = instance.PropertyName();
				snprintf(hack,10,"%d",field->number());
				vars["number"] = hack;
				vars["type"] = instance.getDelphiName();
				vars["label"] = instance.getLableString();

				printer.Print(vars,
					"    // LABEL TYPE $name$ = $number$;\n"
					"    function has_$name$: Boolean;\n"
					"    procedure clear_$name$;\n");

				if (field->label() == FieldDescriptor::LABEL_REPEATED) {
					printer.Print(vars,"    property $name$: $type$ read $pname$;\n");
				} else {
					printer.Print(vars,"    property $name$: $type$ read $pname$ write Set$name$;\n");
				}
				printer.Print("\n");
			}
			printer.Print(
				"  end;\n"
				"\n"
				"implementation\n"
				"\n"
				"uses\n"
				"  pbPublic, Poker.Common.Misc;\n"
				"\n"
				"\n");
			if (needsInit) {
				printer.Print(
					"procedure TPB_$name$.InitObjects;\n"
					"begin\n"
					"  inherited;\n"
					,"name",message->name());
				for (int j=0; j<message->field_count(); j++) {
					const FieldDescriptor *field = message->field(j);
					TypeInfo instance = typeinfo[field->type()]->getInstance(field);

					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						vars["name"] = instance.PropertyName();
						vars["pname"] = instance.PrivateFieldName();
						vars["subname"] = instance.getBaseDelphiName();
						
						if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
							printer.Print(vars,"  $pname$ := TObjectList<$subname$>.Create;\n");
						} else {
							printer.Print(vars,"  $pname$ := TList<$subname$>.Create;\n");
						}
					}
				}
				printer.Print("end;\n");
				printer.Print(
					"procedure TPB_$name$.HookNotifiers;\n"
					"begin\n"
					"  inherited;\n"
					,"name",message->name());
				for (int j=0; j<message->field_count(); j++) {
					const FieldDescriptor *field = message->field(j);
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						TypeInfo instance = typeinfo[field->type()]->getInstance(field);
						printer.Print(
							"  $pname$.OnNotify := $name$NotifyEvent;\n"
							,"name",instance.PropertyName()
							,"pname",instance.PrivateFieldName()
							,"subname",instance.getBaseDelphiName());
					}
				}
				printer.Print("end;\n");
			}
			printer.Print(
				"\n"
//				"{ TPBR_$name$ }\n"
				"constructor TPB_$name$.Create(const AFrom: TPB_$name$);\n"
				"begin\n"
				"  inherited Create;\n"
				"  MergeFrom(AFrom);\n"
				"end;\n\n"
				"destructor TPB_$name$.Destroy;\n"
				"begin\n"
				,"name",message->name());
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				TypeInfo instance = typeinfo[field->type()]->getInstance(field);
				
				if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					if (field->label() == FieldDescriptor::LABEL_REQUIRED) {
						printer.Print(
							"  if Assigned($name$) then\n"
							"    FreeAndNil($name$);\n","name",instance.PrivateFieldName());
					} else if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"  if Assigned($name$) then\n"
							"  begin\n"
							"    $name$.OnNotify := nil;\n"
							"    FreeAndNil($name$);\n"
							"  end;\n"
							,"name",instance.PrivateFieldName());
					} else if (field->label() == FieldDescriptor::LABEL_OPTIONAL) {
						printer.Print("  if Assigned($name$) then FreeAndNil($name$);\n","name",instance.PrivateFieldName());
					}
				} else {
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(
							"  if Assigned($name$) then\n"
							"  begin\n"
							"    $name$.OnNotify := nil;\n"
							"    FreeAndNil($name$);\n"
							"  end;\n"
							,"name",instance.PrivateFieldName());
					}
				}
			}
			printer.Print(
				"  inherited;\n"
				"end;\n"
				"\n"
				"procedure TPB_$name$.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);\n"
				"var\n"
				"  tag,field_number,wire_type,endpos : Integer;\n"
				"begin\n",
				"name",message->name());
			printer.Print(
				"  endpos := AProtobufReader.getPos + ASize;\n"
				"  while (AProtobufReader.getPos < endpos) and\n"
				"        (AProtobufReader.GetNext(tag, wire_type, field_number)) do begin\n"
				"    case field_number of\n");
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				string name = field->name();
				TypeInfo instance = typeinfo[field->type()]->getInstance(field);
				
				UpperString(&name);
				map<string,string> vars;
				vars["name"] = EnumName(field);
				vars["pname"] = instance.PrivateFieldName();
				vars["pubname"] = instance.PropertyName();
				vars["reader"] = typeinfo[field->type()]->getReader();
				vars["wiretype"] = typeinfo[field->type()]->getWireType();
				if ((field->type() == FieldDescriptor::TYPE_INT32) && (field->is_packed())) {
					printer.Print(vars,
						"      $name$: begin\n"
						"        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);\n"
						"        // FIXME $pname$ := AProtobufReader.$reader$;\n"
						"        AProtobufReader.skipField(tag);\n"
						"      end;\n");
				} else if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
					vars["subname"] = instance.getBaseDelphiName();
					printer.Print(vars,
						"      $name$: begin\n"
						"        Assert(wire_type = $wiretype$);\n");
					if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(vars,
							"        $pname$.Add($subname$.Create(AProtobufReader,AProtobufReader.readInt32));\n");
					} else {
						printer.Print(vars,
							"        if not Assigned($pname$) then\n"
							"          $pname$ := $subname$.Create;\n"
							"        $pname$.LoadFromProtobufReader(AProtobufReader,AProtobufReader.readInt32);\n");
					}
					printer.Print(vars,
						"        set_has_$pubname$;\n"
						"      end;\n");
				} else if (field->type() == FieldDescriptor::TYPE_ENUM) {
					const EnumDescriptor *type = field->enum_type();
					vars["subname"] = type->name();
					if (field->label() != FieldDescriptor::LABEL_REPEATED) {
						printer.Print(vars,
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_VARINT);\n"
							"        $pname$ := T$subname$(AProtobufReader.readEnum);\n"
							"        set_has_$pubname$;\n"
							"      end;\n");
					} else if (field->label() == FieldDescriptor::LABEL_REPEATED) {
						printer.Print(vars,
							"      $name$: begin\n"
							"        Assert(wire_type = WIRETYPE_VARINT);\n"
							"        $pname$.Add(T$subname$(AProtobufReader.readEnum));\n"
							"        set_has_$pubname$;\n"
							"      end;\n");
					}
				} else {
					string type = instance.getDelphiName();
					if (!type.empty()) {
						if (field->label() == FieldDescriptor::LABEL_REPEATED) {
							printer.Print(vars,
								"      $name$: begin\n"
								"        Assert(wire_type = $wiretype$);\n"
								"        $pname$.Add(AProtobufReader.$reader$);\n"
								"        set_has_$pubname$;\n"
								"      end;\n");
						} else {
							printer.Print(vars,
								"      $name$: begin\n"
								"        Assert(wire_type = $wiretype$);\n"
								"        $pname$ := AProtobufReader.$reader$;\n"
								"        set_has_$pubname$;\n"
								"      end;\n");
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
				"end;\n"
				"\n");
			printer.Print(
				"procedure TPB_$name$.MergeFrom(const from: TPB_$name$);\n"
				,"name",message->name());
			bool haveVar = false;
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				if (field->label() == FieldDescriptor::LABEL_REPEATED) {
					//if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
						if (!haveVar) {
							haveVar = true;
							printer.Print("var\n");
						}
						TypeInfo instance = typeinfo[field->type()]->getInstance(field);
						snprintf(hack,10,"%d",j);
						printer.Print("  temp$id$: $type$;\n","id",hack,"type",instance.getBaseDelphiName());
					//}
				}
			}
			printer.Print("begin\n");
			for (int j=0; j<message->field_count(); j++) {
				const FieldDescriptor *field = message->field(j);
				TypeInfo instance = typeinfo[field->type()]->getInstance(field);
				
				if ((field->label() == FieldDescriptor::LABEL_REQUIRED) ||
					(field->label() == FieldDescriptor::LABEL_OPTIONAL)) {
					if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
						printer.Print(
							"  if (from.has_$name$) then\n"
							"    $pname$.MergeFrom(from.$name$);\n"
							,"name",instance.PropertyName()
							,"pname",instance.PrivateFieldName());
					} else {
						printer.Print(
							"  if (from.has_$name$) then\n"
							"    Set$name$(from.$name$);\n"
							,"name",instance.PropertyName());
					}
				} else if (field->label() == FieldDescriptor::LABEL_REPEATED) {
					snprintf(hack,10,"%d",j);
					map<string,string> vars2;
					vars2["id"] = hack;
					vars2["pname"] = instance.PrivateFieldName();
					vars2["type"] = instance.getBaseDelphiName();
					vars2["name"] = instance.PropertyName();
					if (field->type() == FieldDescriptor::TYPE_MESSAGE) {
						printer.Print(vars2,
							"  for temp$id$ in from.$name$ do\n"
							"    $pname$.Add($type$.Create(temp$id$));\n"
							);
					} else {
						printer.Print(vars2,
							"  for temp$id$ in from.$name$ do\n"
							"    $pname$.Add(temp$id$); // FIXME?\n"
							);
					}
				}
			}
			printer.Print("end;\n\n");
			GenerateSettersImpl(message,&printer);
			printer.Print(
				"end.\n");
	}
};
class PascalGenerator : public BaseGenerator {
};
class DelphiGenerator : public BaseGenerator {
};
int main(int argc, char *argv[]) {
	typeinfo[FieldDescriptor::TYPE_INT64] = new TypeInfo(FieldDescriptor::TYPE_INT64); // 3
	typeinfo[FieldDescriptor::TYPE_UINT64] = new TypeInfo(FieldDescriptor::TYPE_UINT64);	// 4
	typeinfo[FieldDescriptor::TYPE_INT32] = new TypeInfo(FieldDescriptor::TYPE_INT32);		// 5
	typeinfo[FieldDescriptor::TYPE_BOOL] = new TypeInfo(FieldDescriptor::TYPE_BOOL);		// 8
	typeinfo[FieldDescriptor::TYPE_STRING] = new TypeInfo(FieldDescriptor::TYPE_STRING);	// 9
	typeinfo[FieldDescriptor::TYPE_MESSAGE] = new TypeInfo(FieldDescriptor::TYPE_MESSAGE);	// 11
	typeinfo[FieldDescriptor::TYPE_BYTES] = new TypeInfo(FieldDescriptor::TYPE_BYTES);		// 12
	typeinfo[FieldDescriptor::TYPE_UINT32] = new TypeInfo(FieldDescriptor::TYPE_UINT32);	// 13
	typeinfo[FieldDescriptor::TYPE_ENUM] = new TypeInfo(FieldDescriptor::TYPE_ENUM);		// 14
	cerr << "self " << argv[0] << " " << argc << "\n";
	BaseGenerator *gen;
	if (strcmp("protoc-gen-pascal",argv[0]) == 0) gen = new PascalGenerator();
	else gen = new DelphiGenerator();
	int ret = google::protobuf::compiler::PluginMain(argc,argv,gen);
	delete gen;

	for (int i=0; i<FieldDescriptor::MAX_TYPE; i++) if (typeinfo[i]) delete typeinfo[i];
	return ret;
}
