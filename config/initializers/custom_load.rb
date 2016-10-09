require "limitless_led"
$bridge = LimitlessLed::Bridge.new(host: ENV["MILIGHT_HOST"], port: 8899)

