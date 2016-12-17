class LightController < ApplicationController

	def on
		$bridge.all_on
		render :json => {}
	end

	def off
		$bridge.all_off
		render :json => {}
	end

	def color
		r = params["r"].to_i
		g = params["g"].to_i
		b = params["b"].to_i

		if r == 100 && g == 100 && b == 100
			$bridge.white
		else
			$bridge.color(Color::RGB.from_percentage(r, g, b))  
		end		
		render :json => {}
	end

	def brightness
		brightness = params["brightness"].to_i 
		brightness = 2 + 25 * (brightness / 100)
		$bridge.brightness(brightness)   # 明るさ最小
		render :json => {}
	end

	def alexa
		intent = params["request"]["intent"]["name"]
		
		

		case intent
		when "TurnOnLight"

			response = {
				"version" => "1.0",
				"response" => {
					"outputSpeech" => {
						"type" => "PlainText",
						"text" => "done and done!",
					},
					"shouldEndSession" => true
				}
			}
			render :json => response.to_json

		else
		end



		pp params

	end

end
