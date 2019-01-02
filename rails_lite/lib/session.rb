require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    debugger
    cookie = req.cookies["_rails_lite_app"]
    if cookie
      @session_cookie = JSON.parse(cookie)
    else
      @session_cookie = {}
    end
  end

  def [](key)
    @session_cookie[key]
  end

  def []=(key, val)
    @session_cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    serial = JSON.generate(@session_cookie)
    res.set_cookie("_rails_lite_app", { path: '/', value: serial })
  end
end
