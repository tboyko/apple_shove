module AppleShove
  CONFIG = { 
    :redis_key        => 'apple_shove',
    :reconnect_timer  => 5              # timeout in minutes to re-establish APNS connection  
  }
end