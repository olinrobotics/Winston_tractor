// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: msg.proto

#define INTERNAL_SUPPRESS_PROTOBUF_FIELD_DEPRECATION
#include "msg.pb.h"

#include <algorithm>

#include <google/protobuf/stubs/common.h>
#include <google/protobuf/stubs/once.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/wire_format_lite_inl.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/generated_message_reflection.h>
#include <google/protobuf/reflection_ops.h>
#include <google/protobuf/wire_format.h>
// @@protoc_insertion_point(includes)

namespace msg {

namespace {

const ::google::protobuf::Descriptor* Null_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  Null_reflection_ = NULL;
const ::google::protobuf::Descriptor* Log_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  Log_reflection_ = NULL;
const ::google::protobuf::Descriptor* Time_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  Time_reflection_ = NULL;
const ::google::protobuf::Descriptor* Cmd_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  Cmd_reflection_ = NULL;
const ::google::protobuf::Descriptor* Ack_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  Ack_reflection_ = NULL;
const ::google::protobuf::EnumDescriptor* Mode_descriptor_ = NULL;

}  // namespace


void protobuf_AssignDesc_msg_2eproto() {
  protobuf_AddDesc_msg_2eproto();
  const ::google::protobuf::FileDescriptor* file =
    ::google::protobuf::DescriptorPool::generated_pool()->FindFileByName(
      "msg.proto");
  GOOGLE_CHECK(file != NULL);
  Null_descriptor_ = file->message_type(0);
  static const int Null_offsets_[1] = {
  };
  Null_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      Null_descriptor_,
      Null::default_instance_,
      Null_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Null, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Null, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(Null));
  Log_descriptor_ = file->message_type(1);
  static const int Log_offsets_[1] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Log, text_),
  };
  Log_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      Log_descriptor_,
      Log::default_instance_,
      Log_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Log, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Log, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(Log));
  Time_descriptor_ = file->message_type(2);
  static const int Time_offsets_[1] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Time, times_),
  };
  Time_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      Time_descriptor_,
      Time::default_instance_,
      Time_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Time, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Time, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(Time));
  Cmd_descriptor_ = file->message_type(3);
  static const int Cmd_offsets_[1] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Cmd, mode_),
  };
  Cmd_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      Cmd_descriptor_,
      Cmd::default_instance_,
      Cmd_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Cmd, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Cmd, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(Cmd));
  Ack_descriptor_ = file->message_type(4);
  static const int Ack_offsets_[1] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Ack, mode_),
  };
  Ack_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      Ack_descriptor_,
      Ack::default_instance_,
      Ack_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Ack, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(Ack, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(Ack));
  Mode_descriptor_ = file->enum_type(0);
}

namespace {

GOOGLE_PROTOBUF_DECLARE_ONCE(protobuf_AssignDescriptors_once_);
inline void protobuf_AssignDescriptorsOnce() {
  ::google::protobuf::GoogleOnceInit(&protobuf_AssignDescriptors_once_,
                 &protobuf_AssignDesc_msg_2eproto);
}

void protobuf_RegisterTypes(const ::std::string&) {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    Null_descriptor_, &Null::default_instance());
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    Log_descriptor_, &Log::default_instance());
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    Time_descriptor_, &Time::default_instance());
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    Cmd_descriptor_, &Cmd::default_instance());
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    Ack_descriptor_, &Ack::default_instance());
}

}  // namespace

void protobuf_ShutdownFile_msg_2eproto() {
  delete Null::default_instance_;
  delete Null_reflection_;
  delete Log::default_instance_;
  delete Log_reflection_;
  delete Time::default_instance_;
  delete Time_reflection_;
  delete Cmd::default_instance_;
  delete Cmd_reflection_;
  delete Ack::default_instance_;
  delete Ack_reflection_;
}

void protobuf_AddDesc_msg_2eproto() {
  static bool already_here = false;
  if (already_here) return;
  already_here = true;
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  ::google::protobuf::DescriptorPool::InternalAddGeneratedFile(
    "\n\tmsg.proto\022\003msg\"\006\n\004Null\"\023\n\003Log\022\014\n\004text\030"
    "\001 \002(\t\"\025\n\004Time\022\r\n\005timeS\030\001 \002(\001\"\036\n\003Cmd\022\027\n\004m"
    "ode\030\001 \002(\0162\t.msg.Mode\"\036\n\003Ack\022\027\n\004mode\030\001 \002("
    "\0162\t.msg.Mode*\"\n\004Mode\022\007\n\003OFF\020\000\022\010\n\004IDLE\020\001\022"
    "\007\n\003RUN\020\002B\007\n\000B\003msg", 177);
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedFile(
    "msg.proto", &protobuf_RegisterTypes);
  Null::default_instance_ = new Null();
  Log::default_instance_ = new Log();
  Time::default_instance_ = new Time();
  Cmd::default_instance_ = new Cmd();
  Ack::default_instance_ = new Ack();
  Null::default_instance_->InitAsDefaultInstance();
  Log::default_instance_->InitAsDefaultInstance();
  Time::default_instance_->InitAsDefaultInstance();
  Cmd::default_instance_->InitAsDefaultInstance();
  Ack::default_instance_->InitAsDefaultInstance();
  ::google::protobuf::internal::OnShutdown(&protobuf_ShutdownFile_msg_2eproto);
}

// Force AddDescriptors() to be called at static initialization time.
struct StaticDescriptorInitializer_msg_2eproto {
  StaticDescriptorInitializer_msg_2eproto() {
    protobuf_AddDesc_msg_2eproto();
  }
} static_descriptor_initializer_msg_2eproto_;
const ::google::protobuf::EnumDescriptor* Mode_descriptor() {
  protobuf_AssignDescriptorsOnce();
  return Mode_descriptor_;
}
bool Mode_IsValid(int value) {
  switch(value) {
    case 0:
    case 1:
    case 2:
      return true;
    default:
      return false;
  }
}


// ===================================================================

#ifndef _MSC_VER
#endif  // !_MSC_VER

Null::Null()
  : ::google::protobuf::Message() {
  SharedCtor();
  // @@protoc_insertion_point(constructor:msg.Null)
}

void Null::InitAsDefaultInstance() {
}

Null::Null(const Null& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
  // @@protoc_insertion_point(copy_constructor:msg.Null)
}

void Null::SharedCtor() {
  _cached_size_ = 0;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

Null::~Null() {
  // @@protoc_insertion_point(destructor:msg.Null)
  SharedDtor();
}

void Null::SharedDtor() {
  if (this != default_instance_) {
  }
}

void Null::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* Null::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return Null_descriptor_;
}

const Null& Null::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_msg_2eproto();
  return *default_instance_;
}

Null* Null::default_instance_ = NULL;

Null* Null::New() const {
  return new Null;
}

void Null::Clear() {
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool Null::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) goto failure
  ::google::protobuf::uint32 tag;
  // @@protoc_insertion_point(parse_start:msg.Null)
  for (;;) {
    ::std::pair< ::google::protobuf::uint32, bool> p = input->ReadTagWithCutoff(127);
    tag = p.first;
    if (!p.second) goto handle_unusual;
  handle_unusual:
    if (tag == 0 ||
        ::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
        ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
      goto success;
    }
    DO_(::google::protobuf::internal::WireFormat::SkipField(
          input, tag, mutable_unknown_fields()));
  }
success:
  // @@protoc_insertion_point(parse_success:msg.Null)
  return true;
failure:
  // @@protoc_insertion_point(parse_failure:msg.Null)
  return false;
#undef DO_
}

void Null::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // @@protoc_insertion_point(serialize_start:msg.Null)
  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
  // @@protoc_insertion_point(serialize_end:msg.Null)
}

::google::protobuf::uint8* Null::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // @@protoc_insertion_point(serialize_to_array_start:msg.Null)
  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  // @@protoc_insertion_point(serialize_to_array_end:msg.Null)
  return target;
}

int Null::ByteSize() const {
  int total_size = 0;

  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void Null::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const Null* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const Null*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void Null::MergeFrom(const Null& from) {
  GOOGLE_CHECK_NE(&from, this);
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void Null::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void Null::CopyFrom(const Null& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool Null::IsInitialized() const {

  return true;
}

void Null::Swap(Null* other) {
  if (other != this) {
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata Null::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = Null_descriptor_;
  metadata.reflection = Null_reflection_;
  return metadata;
}


// ===================================================================

#ifndef _MSC_VER
const int Log::kTextFieldNumber;
#endif  // !_MSC_VER

Log::Log()
  : ::google::protobuf::Message() {
  SharedCtor();
  // @@protoc_insertion_point(constructor:msg.Log)
}

void Log::InitAsDefaultInstance() {
}

Log::Log(const Log& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
  // @@protoc_insertion_point(copy_constructor:msg.Log)
}

void Log::SharedCtor() {
  ::google::protobuf::internal::GetEmptyString();
  _cached_size_ = 0;
  text_ = const_cast< ::std::string*>(&::google::protobuf::internal::GetEmptyStringAlreadyInited());
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

Log::~Log() {
  // @@protoc_insertion_point(destructor:msg.Log)
  SharedDtor();
}

void Log::SharedDtor() {
  if (text_ != &::google::protobuf::internal::GetEmptyStringAlreadyInited()) {
    delete text_;
  }
  if (this != default_instance_) {
  }
}

void Log::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* Log::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return Log_descriptor_;
}

const Log& Log::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_msg_2eproto();
  return *default_instance_;
}

Log* Log::default_instance_ = NULL;

Log* Log::New() const {
  return new Log;
}

void Log::Clear() {
  if (has_text()) {
    if (text_ != &::google::protobuf::internal::GetEmptyStringAlreadyInited()) {
      text_->clear();
    }
  }
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool Log::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) goto failure
  ::google::protobuf::uint32 tag;
  // @@protoc_insertion_point(parse_start:msg.Log)
  for (;;) {
    ::std::pair< ::google::protobuf::uint32, bool> p = input->ReadTagWithCutoff(127);
    tag = p.first;
    if (!p.second) goto handle_unusual;
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // required string text = 1;
      case 1: {
        if (tag == 10) {
          DO_(::google::protobuf::internal::WireFormatLite::ReadString(
                input, this->mutable_text()));
          ::google::protobuf::internal::WireFormat::VerifyUTF8StringNamedField(
            this->text().data(), this->text().length(),
            ::google::protobuf::internal::WireFormat::PARSE,
            "text");
        } else {
          goto handle_unusual;
        }
        if (input->ExpectAtEnd()) goto success;
        break;
      }

      default: {
      handle_unusual:
        if (tag == 0 ||
            ::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          goto success;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
success:
  // @@protoc_insertion_point(parse_success:msg.Log)
  return true;
failure:
  // @@protoc_insertion_point(parse_failure:msg.Log)
  return false;
#undef DO_
}

void Log::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // @@protoc_insertion_point(serialize_start:msg.Log)
  // required string text = 1;
  if (has_text()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8StringNamedField(
      this->text().data(), this->text().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE,
      "text");
    ::google::protobuf::internal::WireFormatLite::WriteStringMaybeAliased(
      1, this->text(), output);
  }

  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
  // @@protoc_insertion_point(serialize_end:msg.Log)
}

::google::protobuf::uint8* Log::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // @@protoc_insertion_point(serialize_to_array_start:msg.Log)
  // required string text = 1;
  if (has_text()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8StringNamedField(
      this->text().data(), this->text().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE,
      "text");
    target =
      ::google::protobuf::internal::WireFormatLite::WriteStringToArray(
        1, this->text(), target);
  }

  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  // @@protoc_insertion_point(serialize_to_array_end:msg.Log)
  return target;
}

int Log::ByteSize() const {
  int total_size = 0;

  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // required string text = 1;
    if (has_text()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::StringSize(
          this->text());
    }

  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void Log::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const Log* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const Log*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void Log::MergeFrom(const Log& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_text()) {
      set_text(from.text());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void Log::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void Log::CopyFrom(const Log& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool Log::IsInitialized() const {
  if ((_has_bits_[0] & 0x00000001) != 0x00000001) return false;

  return true;
}

void Log::Swap(Log* other) {
  if (other != this) {
    std::swap(text_, other->text_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata Log::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = Log_descriptor_;
  metadata.reflection = Log_reflection_;
  return metadata;
}


// ===================================================================

#ifndef _MSC_VER
const int Time::kTimeSFieldNumber;
#endif  // !_MSC_VER

Time::Time()
  : ::google::protobuf::Message() {
  SharedCtor();
  // @@protoc_insertion_point(constructor:msg.Time)
}

void Time::InitAsDefaultInstance() {
}

Time::Time(const Time& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
  // @@protoc_insertion_point(copy_constructor:msg.Time)
}

void Time::SharedCtor() {
  _cached_size_ = 0;
  times_ = 0;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

Time::~Time() {
  // @@protoc_insertion_point(destructor:msg.Time)
  SharedDtor();
}

void Time::SharedDtor() {
  if (this != default_instance_) {
  }
}

void Time::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* Time::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return Time_descriptor_;
}

const Time& Time::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_msg_2eproto();
  return *default_instance_;
}

Time* Time::default_instance_ = NULL;

Time* Time::New() const {
  return new Time;
}

void Time::Clear() {
  times_ = 0;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool Time::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) goto failure
  ::google::protobuf::uint32 tag;
  // @@protoc_insertion_point(parse_start:msg.Time)
  for (;;) {
    ::std::pair< ::google::protobuf::uint32, bool> p = input->ReadTagWithCutoff(127);
    tag = p.first;
    if (!p.second) goto handle_unusual;
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // required double timeS = 1;
      case 1: {
        if (tag == 9) {
          DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                   double, ::google::protobuf::internal::WireFormatLite::TYPE_DOUBLE>(
                 input, &times_)));
          set_has_times();
        } else {
          goto handle_unusual;
        }
        if (input->ExpectAtEnd()) goto success;
        break;
      }

      default: {
      handle_unusual:
        if (tag == 0 ||
            ::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          goto success;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
success:
  // @@protoc_insertion_point(parse_success:msg.Time)
  return true;
failure:
  // @@protoc_insertion_point(parse_failure:msg.Time)
  return false;
#undef DO_
}

void Time::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // @@protoc_insertion_point(serialize_start:msg.Time)
  // required double timeS = 1;
  if (has_times()) {
    ::google::protobuf::internal::WireFormatLite::WriteDouble(1, this->times(), output);
  }

  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
  // @@protoc_insertion_point(serialize_end:msg.Time)
}

::google::protobuf::uint8* Time::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // @@protoc_insertion_point(serialize_to_array_start:msg.Time)
  // required double timeS = 1;
  if (has_times()) {
    target = ::google::protobuf::internal::WireFormatLite::WriteDoubleToArray(1, this->times(), target);
  }

  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  // @@protoc_insertion_point(serialize_to_array_end:msg.Time)
  return target;
}

int Time::ByteSize() const {
  int total_size = 0;

  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // required double timeS = 1;
    if (has_times()) {
      total_size += 1 + 8;
    }

  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void Time::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const Time* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const Time*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void Time::MergeFrom(const Time& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_times()) {
      set_times(from.times());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void Time::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void Time::CopyFrom(const Time& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool Time::IsInitialized() const {
  if ((_has_bits_[0] & 0x00000001) != 0x00000001) return false;

  return true;
}

void Time::Swap(Time* other) {
  if (other != this) {
    std::swap(times_, other->times_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata Time::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = Time_descriptor_;
  metadata.reflection = Time_reflection_;
  return metadata;
}


// ===================================================================

#ifndef _MSC_VER
const int Cmd::kModeFieldNumber;
#endif  // !_MSC_VER

Cmd::Cmd()
  : ::google::protobuf::Message() {
  SharedCtor();
  // @@protoc_insertion_point(constructor:msg.Cmd)
}

void Cmd::InitAsDefaultInstance() {
}

Cmd::Cmd(const Cmd& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
  // @@protoc_insertion_point(copy_constructor:msg.Cmd)
}

void Cmd::SharedCtor() {
  _cached_size_ = 0;
  mode_ = 0;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

Cmd::~Cmd() {
  // @@protoc_insertion_point(destructor:msg.Cmd)
  SharedDtor();
}

void Cmd::SharedDtor() {
  if (this != default_instance_) {
  }
}

void Cmd::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* Cmd::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return Cmd_descriptor_;
}

const Cmd& Cmd::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_msg_2eproto();
  return *default_instance_;
}

Cmd* Cmd::default_instance_ = NULL;

Cmd* Cmd::New() const {
  return new Cmd;
}

void Cmd::Clear() {
  mode_ = 0;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool Cmd::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) goto failure
  ::google::protobuf::uint32 tag;
  // @@protoc_insertion_point(parse_start:msg.Cmd)
  for (;;) {
    ::std::pair< ::google::protobuf::uint32, bool> p = input->ReadTagWithCutoff(127);
    tag = p.first;
    if (!p.second) goto handle_unusual;
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // required .msg.Mode mode = 1;
      case 1: {
        if (tag == 8) {
          int value;
          DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                   int, ::google::protobuf::internal::WireFormatLite::TYPE_ENUM>(
                 input, &value)));
          if (::msg::Mode_IsValid(value)) {
            set_mode(static_cast< ::msg::Mode >(value));
          } else {
            mutable_unknown_fields()->AddVarint(1, value);
          }
        } else {
          goto handle_unusual;
        }
        if (input->ExpectAtEnd()) goto success;
        break;
      }

      default: {
      handle_unusual:
        if (tag == 0 ||
            ::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          goto success;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
success:
  // @@protoc_insertion_point(parse_success:msg.Cmd)
  return true;
failure:
  // @@protoc_insertion_point(parse_failure:msg.Cmd)
  return false;
#undef DO_
}

void Cmd::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // @@protoc_insertion_point(serialize_start:msg.Cmd)
  // required .msg.Mode mode = 1;
  if (has_mode()) {
    ::google::protobuf::internal::WireFormatLite::WriteEnum(
      1, this->mode(), output);
  }

  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
  // @@protoc_insertion_point(serialize_end:msg.Cmd)
}

::google::protobuf::uint8* Cmd::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // @@protoc_insertion_point(serialize_to_array_start:msg.Cmd)
  // required .msg.Mode mode = 1;
  if (has_mode()) {
    target = ::google::protobuf::internal::WireFormatLite::WriteEnumToArray(
      1, this->mode(), target);
  }

  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  // @@protoc_insertion_point(serialize_to_array_end:msg.Cmd)
  return target;
}

int Cmd::ByteSize() const {
  int total_size = 0;

  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // required .msg.Mode mode = 1;
    if (has_mode()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::EnumSize(this->mode());
    }

  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void Cmd::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const Cmd* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const Cmd*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void Cmd::MergeFrom(const Cmd& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_mode()) {
      set_mode(from.mode());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void Cmd::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void Cmd::CopyFrom(const Cmd& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool Cmd::IsInitialized() const {
  if ((_has_bits_[0] & 0x00000001) != 0x00000001) return false;

  return true;
}

void Cmd::Swap(Cmd* other) {
  if (other != this) {
    std::swap(mode_, other->mode_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata Cmd::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = Cmd_descriptor_;
  metadata.reflection = Cmd_reflection_;
  return metadata;
}


// ===================================================================

#ifndef _MSC_VER
const int Ack::kModeFieldNumber;
#endif  // !_MSC_VER

Ack::Ack()
  : ::google::protobuf::Message() {
  SharedCtor();
  // @@protoc_insertion_point(constructor:msg.Ack)
}

void Ack::InitAsDefaultInstance() {
}

Ack::Ack(const Ack& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
  // @@protoc_insertion_point(copy_constructor:msg.Ack)
}

void Ack::SharedCtor() {
  _cached_size_ = 0;
  mode_ = 0;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

Ack::~Ack() {
  // @@protoc_insertion_point(destructor:msg.Ack)
  SharedDtor();
}

void Ack::SharedDtor() {
  if (this != default_instance_) {
  }
}

void Ack::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* Ack::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return Ack_descriptor_;
}

const Ack& Ack::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_msg_2eproto();
  return *default_instance_;
}

Ack* Ack::default_instance_ = NULL;

Ack* Ack::New() const {
  return new Ack;
}

void Ack::Clear() {
  mode_ = 0;
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool Ack::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) goto failure
  ::google::protobuf::uint32 tag;
  // @@protoc_insertion_point(parse_start:msg.Ack)
  for (;;) {
    ::std::pair< ::google::protobuf::uint32, bool> p = input->ReadTagWithCutoff(127);
    tag = p.first;
    if (!p.second) goto handle_unusual;
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // required .msg.Mode mode = 1;
      case 1: {
        if (tag == 8) {
          int value;
          DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                   int, ::google::protobuf::internal::WireFormatLite::TYPE_ENUM>(
                 input, &value)));
          if (::msg::Mode_IsValid(value)) {
            set_mode(static_cast< ::msg::Mode >(value));
          } else {
            mutable_unknown_fields()->AddVarint(1, value);
          }
        } else {
          goto handle_unusual;
        }
        if (input->ExpectAtEnd()) goto success;
        break;
      }

      default: {
      handle_unusual:
        if (tag == 0 ||
            ::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          goto success;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
success:
  // @@protoc_insertion_point(parse_success:msg.Ack)
  return true;
failure:
  // @@protoc_insertion_point(parse_failure:msg.Ack)
  return false;
#undef DO_
}

void Ack::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // @@protoc_insertion_point(serialize_start:msg.Ack)
  // required .msg.Mode mode = 1;
  if (has_mode()) {
    ::google::protobuf::internal::WireFormatLite::WriteEnum(
      1, this->mode(), output);
  }

  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
  // @@protoc_insertion_point(serialize_end:msg.Ack)
}

::google::protobuf::uint8* Ack::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // @@protoc_insertion_point(serialize_to_array_start:msg.Ack)
  // required .msg.Mode mode = 1;
  if (has_mode()) {
    target = ::google::protobuf::internal::WireFormatLite::WriteEnumToArray(
      1, this->mode(), target);
  }

  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  // @@protoc_insertion_point(serialize_to_array_end:msg.Ack)
  return target;
}

int Ack::ByteSize() const {
  int total_size = 0;

  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // required .msg.Mode mode = 1;
    if (has_mode()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::EnumSize(this->mode());
    }

  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void Ack::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const Ack* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const Ack*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void Ack::MergeFrom(const Ack& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_mode()) {
      set_mode(from.mode());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void Ack::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void Ack::CopyFrom(const Ack& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool Ack::IsInitialized() const {
  if ((_has_bits_[0] & 0x00000001) != 0x00000001) return false;

  return true;
}

void Ack::Swap(Ack* other) {
  if (other != this) {
    std::swap(mode_, other->mode_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata Ack::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = Ack_descriptor_;
  metadata.reflection = Ack_reflection_;
  return metadata;
}


// @@protoc_insertion_point(namespace_scope)

}  // namespace msg

// @@protoc_insertion_point(global_scope)
