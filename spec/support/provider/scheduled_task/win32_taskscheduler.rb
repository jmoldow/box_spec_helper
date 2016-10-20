# -*- encoding : utf-8 -*-

# These constants are needed for validation in
# <https://github.com/puppetlabs/puppet/blob/3.7.5/lib/puppet/provider/scheduled_task/win32_taskscheduler.rb>.
#
# They are normally defined in <https://rubygems.org/gems/win32-taskscheduler>
# or
# <https://github.com/puppetlabs/puppet/blob/3.7.5/lib/puppet/util/windows/taskscheduler.rb>
# but those files cannot be imported on Linux.
#
# For the sake of getting provider/scheduled_task/win32_taskscheduler.rb to not
# fail at validation time, it just matters that these constants are defined in
# the Win32::TaskScheduler namespace, with unique values (for the
# TASK_TIME_TRIGGER_* constants and aliases) or integral powers of two (for the
# TASK_TRIGGER_FLAG_* constants). It doesn't particularly matter what the
# values are, though we've copied the values from Puppet for consistency.

module Win32
  class TaskScheduler
    TASK_TIME_TRIGGER_ONCE            = :TASK_TIME_TRIGGER_ONCE
    TASK_TIME_TRIGGER_DAILY           = :TASK_TIME_TRIGGER_DAILY
    TASK_TIME_TRIGGER_WEEKLY          = :TASK_TIME_TRIGGER_WEEKLY
    TASK_TIME_TRIGGER_MONTHLYDATE     = :TASK_TIME_TRIGGER_MONTHLYDATE
    TASK_TIME_TRIGGER_MONTHLYDOW      = :TASK_TIME_TRIGGER_MONTHLYDOW

    TASK_TRIGGER_FLAG_DISABLED  = 0x4

    ONCE = TASK_TIME_TRIGGER_ONCE
    DAILY = TASK_TIME_TRIGGER_DAILY
    WEEKLY = TASK_TIME_TRIGGER_WEEKLY
    MONTHLYDATE = TASK_TIME_TRIGGER_MONTHLYDATE
    MONTHLYDOW = TASK_TIME_TRIGGER_MONTHLYDOW
  end
end
