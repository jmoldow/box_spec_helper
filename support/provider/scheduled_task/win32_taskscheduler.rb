# -*- encoding : utf-8 -*-

# These constants are needed for validation in
# <https://github.com/puppetlabs/puppet/blob/master/lib/puppet/provider/scheduled_task/win32_taskscheduler.rb>.
#
# They are normally defined in
# <https://github.com/puppetlabs/puppet/blob/master/lib/puppet/util/windows/taskscheduler.rb>
# but that file cannot be imported on Linux.

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
