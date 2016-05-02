# -*- encoding : utf-8 -*-

require 'support/verbose'

module Kernel

  # Emit a warning that displays prominently in the terminal.
  #
  # Wrap the message with extra leading and trailing newlines, so that it is spatially
  # separated from other output. And also use the ANSI escape codes [1] provided in the
  # `style` string parameter (defaults to red and bold) to provide extra emphasis.
  #
  # Finally, make sure that the $VERBOSE setting is enabled, so that the message is not
  # suppressed.
  #
  # [1] <https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_codes>
  def warn_with_emphasis(message, style=nil)
    style ||= "\e[31m\e[1m"
    with_verbose do
      warn "\n#{style}#{message}\e[0m\n"
    end
  end
end
