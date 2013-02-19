require "temper/version"

module Temper
  class PID
    attr_accessor :kp, :ki, :kd, :setpoint, :direction, :output

    def initialize options = {}
      @interval = options[:interval] || 1000
      @last_time = 0.0
      @last_input = 0.0
      @integral_term = 0.0
      @output_maximum = options[:maximum] || 1000
      @output_minimum = options[:minimum] || 0

      set_mode options[:mode] || :auto
      set_direction options[:direction] || :direct
    end

    def control input
      return if !@auto # manual mode

      now = Time.now.to_f
      time_change = (now - @last_time) * 1000

      if time_change >= @interval
        error = @setpoint - input

        calculate_proportional error
        calculate_integral error
        calculate_derivative input

        calculate_output

        @last_time = now
        @last_input = input

        @output
      end
    end

    def calculate_proportional error
      @proportional_term = @kp * error
    end

    def calculate_integral error
      @integral_term += @ki * error

      if @integral_term > @output_maximum
        @integral_term = @output_maximum
      elsif @integral_term < @output_minimum
        @integral_term = @output_minimum
      end
    end

    def calculate_derivative input
      @derivative_term = @kd * (input - @last_input)
    end

    def calculate_output
      @output = @proportional_term + @integral_term - @derivative_term

      if @output > @output_maximum
        @output = @output_maximum
      elsif @output < @output_minimum
        @output = @output_minimum
      end

      @output
    end

    def tune kp, ki, kd
      return if kp < 0 || ki < 0 || kd < 0

      interval_seconds = (@interval / 1000.0)

      @kp = kp
      @ki = ki * interval_seconds
      @kd = kd / interval_seconds

      if @direction != :direct
        @kp = 0 - @kp
        @ki = 0 - @ki
        @kd = 0 - @kd
      end
    end

    def update_interval new_interval
      if new_interval > 0
        ratio = new_interval / @interval

        @ki *= ratio
        @kd /= ratio
        @interval = new_interval
      end
    end

    def set_mode mode
      @auto = mode == :auto
    end

    def set_direction direction
      @direction = direction
    end

    def mode
      @auto ? :auto : :manual
    end
  end
end
