namespace Msg
{
  Log::Log(App* msgApp)
  {
    this->msgApp = msgApp;
    if(this->msgApp->msgAppID.empty())
    {
      throw("Log: App must be initialized before Log");
    }
  }
  
  // Send a log message at the next opportunity.
  //
  // @param[in] format   @see sprintf()
  // @param[in] varargin @see sprintf()
  void Log::log(const char* format, ...)
  {
    std::string text;
    msg::Log msgLog;
    int bytes;
    va_list args;
    va_start(args, format);
    bytes = vsnprintf(NULL, 0, format, args);
    va_end(args);
    text.resize(bytes);
    va_start(args, format);
    vsnprintf(&text[0], bytes+1, format, args); // writes one less than the second argument
    va_end(args);
    msgLog.set_text(text);
    this->msgApp->send(Msg::Proto::pack("msg.Log", this->msgApp->msgAppID, msgLog.SerializeAsString()));
    return;
  }
}
