#ifndef MSGPROTO_H
#define MSGPROTO_H

#include <string>
#include <vector>
#include "msg/msg.pb.cc"

namespace Msg
{
  // Protocol tools.
  //
  // @see dependencies in README.txt
  class Proto
  {
  public:
    // Assemble message header.
    //
    // @param[in]  type   message type as a string
    // @param[in]  id     extended identifier as a string
    // @param[out] header initial bytes of a message not including a terminating null character
    static void topic(const std::string& type, const std::string& id, std::string& header)
    {
      static const char nc = '\0';
      header = type;
      if(id.size()>0)
      {
        header = header+nc+id;
      }
      return;
    }
    static std::string topic(const std::string& type, const std::string& id)
    {
      std::string header;
      Msg::Proto::topic(type, id, header);
      return header;
    }
    
    // Determine whether the message matches the topic.
    //
    // @param[in]  message reference message
    // @param[in]  header  initial bytes to test against the message
    // @param[out] flag    true if all header bytes match the message
    static bool isTopic(const std::string& message, const std::string& header)
    {
      return (!message.compare(0, header.size(), header));
    }
    
    // Pack a message.
    //
    // @param[in]  type    message type as a string
    // @param[in]  id      extended identifier as a string
    // @param[in]  data    serialized protobuf
    // @param[out] message packed message as a string
    static void pack(const std::string& type, const std::string& id, const std::string& data, std::string& message)
    {
      static const char nc = '\0';
      message = type+nc+id+nc;
      message += data;
      return;
    }
    static std::string pack(const std::string& type, const std::string& id, const std::string& data)
    {
      std::string message;
      Msg::Proto::pack(type, id, data, message);
      return message;
    }
    
    // Unpack a message.
    //
    // @param[in]  message packed message as a string
    // @param[out] type    message type as a string
    // @param[out] id      extended identifier as a string
    // @param[out] data    serialized protobuf
    static void unpack(const std::string& message, std::string& type, std::string& id, std::string& data)
    {
      static const char nc = '\0';
      size_t K;
      size_t k;
      size_t ka;
      size_t kb;
      
      // get message size
      K = message.size();

      // find first null character if present
      ka = K;
      for(k = 0; k<K; ++k)
      {
        if(message[k]==nc)
        {
          ka = k;
          break;
        }
      }

      // find second null character if present
      kb = K;
      for(k = ka+1; k<K; ++k)
      {
        if(message[k]==nc)
        {
          kb = k;
          break;
        }
      }

      // check message format
      if((ka<K)&&(kb<K))
      {
        type.assign(message, 0, ka);
        id.assign(message, ka+1, kb-ka-1);
        data.assign(message, kb+1, K-kb-1);
      }
      else
      {
        type.clear();
        id.clear();
        data.clear();
      }
      return;
    }
    static std::string unpack(const std::string& message, std::string& type, std::string& id)
    {
      std::string data;
      Msg::Proto::unpack(message, type, id, data);
      return data;
    }
    
  private:
    Proto(void)
    {}
  };
}

#endif
