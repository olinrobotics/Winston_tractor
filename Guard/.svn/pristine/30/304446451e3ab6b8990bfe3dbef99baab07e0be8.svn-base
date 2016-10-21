#ifndef MSGPROXY_H
#define MSGPROXY_H

#include <zmq.h>

namespace Msg
{
  void Proxy(const char* subURI, const char* pubURI, const bool bind = true) 
  {
    static const int LINGER = 2000;
    static const int RCVHWM = 10000;
    static const int SNDHWM = 10000;
    
    void *context = zmq_ctx_new();
    if(context==NULL)
    {
      throw("ZMQ: Failed to create context.");
    }
    
    void *subSocket = zmq_socket(context, ZMQ_XSUB);
    if(subSocket==NULL)
    {
      throw("ZMQ: Failed to create SUB socket.");
    }
    zmq_setsockopt(subSocket, ZMQ_LINGER, &LINGER, sizeof(int));
    zmq_setsockopt(subSocket, ZMQ_RCVHWM, &RCVHWM, sizeof(int));
    zmq_setsockopt(subSocket, ZMQ_SUBSCRIBE, "", 0);
    
    if(bind)
    {
      if(zmq_bind(subSocket, subURI))
      {
        throw("ZMQ: Failed to bind to SUB socket.");
      }
    }
    else
    {
      if(zmq_connect(subSocket, subURI))
      {
        throw("ZMQ: Failed to connect to SUB socket.");
      }
    }
    
    void *pubSocket = zmq_socket(context, ZMQ_XPUB);
    if(subSocket==NULL)
    {
      throw("ZMQ: Failed to create PUB socket.");
    }
    zmq_setsockopt(pubSocket, ZMQ_LINGER, &LINGER, sizeof(int));
    zmq_setsockopt(pubSocket, ZMQ_SNDHWM, &SNDHWM, sizeof(int));
    
    if(bind)
    {
      if(zmq_bind(pubSocket, pubURI))
      {
        throw("ZMQ: Failed to bind to PUB socket.");
      }
    }
    else
    {
      if(zmq_connect(pubSocket, pubURI))
      {
        throw("ZMQ: Failed to connect to PUB socket.");
      }
    }
    
    zmq_proxy(subSocket, pubSocket, NULL); // blocks forever
    return;
  }
}

#endif
