class Commander::Parser
  class Exception < Commander::Exception; end

  FORMATS = [LongFlagFormat, ShortFlagFormat]

  getter params : Params
  getter flags : Flags

  getter options : Options
  getter arguments : Arguments
  getter skip : Array(Int32)
  getter? ignore_unmapped_flags : Bool

  protected def initialize(@params : Params, @flags : Flags, @ignore_unmapped_flags = false)
    @options = Options.new
    @arguments = Arguments.new
    @skip = Array(Int32).new
  end

  protected def parse
    set_defaults!
    build
  end

  private def set_defaults!
    flags.each { |flag| options.set(flag.name, flag.default) }
  end

  private def build
    params.each_with_index do |param, index|
      next if skip.includes?(index)

      if param == "--"
        rest_params = params[(index + 1)...(params.size)]
        arguments.concat(rest_params)
        break
      end

      is_argument = true
      next_param = params[index + 1]?
      skip_next = ->{ skip << index + 1 }

      FORMATS.each do |format|
        fmt = format.new(
          param,
          next_param,
          skip_next,
          flags,
          options,
          ignore_unmapped_flags: ignore_unmapped_flags?,
        )

        if fmt.match? && fmt.parse!
          is_argument = false
          break
        end
      end

      arguments << param if is_argument
    end

    {options, arguments}
  end
end

require "./parser/*"
