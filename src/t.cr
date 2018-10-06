require "./t/*"
require "time"

# TODO: Write documentation for `T`
module T
extend self

DEFAULT_FILENAME="#{ENV["HOME"]}#{File::SEPARATOR}.t"

class TimeEntry
    getter start_time, end_time, project
    def initialize(@start_time : Time, end_time : Time | Nil, @project : String)
        if end_time.nil?
            @end_time = end_time
        elsif end_time < @start_time
            @end_time = end_time + Time::Span.new(12,0,0) 
        else
            @end_time = end_time
        end
    end

    def initialize(@start_time : Time, @end_time : Time | Nil)
        @project = "Default"
        if @end_time.nil?
            @end_time = @end_time + Time::Span.new(12,0,0) if @end_time < @start_time
        else
            @end_time = nil
        end
    end

    def initialize(@start_time : Time)
        @end_time = nil
        @project = "Default"
    end    

    def time_worked()
        tmp = @end_time
        if tmp.nil?
            tmp = Time.now() 
        end
        #puts "START  #{@start_time}"
        #puts "END    #{tmp}"
        #puts "SPAN   #{tmp - @start_time}"
        tmp - @start_time
    end

    def to_s(io)
        tmp = @end_time
        if tmp
            tmp = "#{tmp.to_s("%H:%M")}".ljust(5)
            io << "#{@start_time.to_s("%H:%M")}-#{tmp} (#{@project})"
        else
            io << "#{@start_time.to_s("%H:%M")}-      (#{@project})"
        end
    end
end

class WorkDay
    def initialize(filename : String)
        @worked = [] of TimeEntry
        File.open(filename, "r").each_line do |line|
            worked = T.parse_timespan(line)
            if worked
                @worked.push(worked)
            else
                # Something about an error here
                puts "ERROR parsing #{line}"
            end
        end
    end

    def initialize()
        initialize(DEFAULT_FILENAME)
    end

    def last()
        @worked.last() 
    end

    def summary()
        total = 0.0
        project = Hash(String, Float32).new(0.0)
        @worked.each do |entry|
            project[entry.project] += entry.time_worked().total_hours()
            total += entry.time_worked().total_hours()
        end
        return project, total
    end

    def to_s(io)
        @worked.each do |entry|
            io << "#{entry}\n"
        end
    end
end

def parse_time(line)
    re_time = /([0-9]{1,2}:[0-9]{2})/
    re_time = /([0-9]{1,2}:[0-9]{2})\s*(\(\w+)\)?/
    match = re_time.match(line)
    if match
        init = Time.now()
        time = Time.parse(match[1], "%H:%M", Time::Location.load("America/New_York"))
        time = Time.new(init.year, init.month, init.day, time.hour, time.minute)
        return time 
    end
end

def parse_timespan(line)
    re_time = /([0-9]{1,2}:[0-9]{2})(-)([0-9]{1,2}:[0-9]{2})?\s*(\((\w+)\))?/
    match = re_time.match(line)
    if match
        init = Time.now()
        start_time = Time.parse(match[1], "%H:%M", Time::Location.load("America/New_York"))
        start_time = Time.new(init.year, init.month, init.day, start_time.hour, start_time.minute)
        begin
            init = Time.now()
            end_time = Time.parse(match[3], "%H:%M", Time::Location.load("America/New_York"))
            end_time = Time.new(init.year, init.month, init.day, end_time.hour, end_time.minute)
        rescue
            end_time = nil
        end

        begin
            project = match[5]
        rescue
            project = "Default"
        end

        return TimeEntry.new(start_time, end_time, project)
    end

end


def read_file()
    ret = [] of TimeEntry
    lines = File.read_lines(DEFAULT_FILENAME)
    lines.each_line do |line|
        span = parse_timespan(line)
    end 
    ret
end

def write_file(entries , filename=DEFAULT_FILENAME)
    File.open(filename, "w") do |fout|
        entries.each do |entry|
            fout.puts(entry.to_s + "\n")
        end 
    end
end

end

#w = T::WorkDay.new()
#print w
#s, total = w.summary()
#puts total

#exit(0)
if ARGV.size > 0
    sum = 0
    entries = [] of T::TimeEntry
    if ARGV[0] == "in" 
        if ARGV.size() == 1
            time = Time.now()
        else
            time = T.parse_time(ARGV[1..-1].join(" "))
        end
    elsif  ARGV[0] == "out"
        if ARGV.size() == 1
            time = Time.now()
        else
            time = T.parse_time(ARGV[ 1..-1].join(" "))
        end
    else
        ARGV.each do |arg|
            worked = T.parse_timespan(arg) 
            if worked
                puts "#{worked} (#{worked.time_worked()})" 
                entries.push(worked)
                sum += worked.time_worked().total_hours()
            end
        end
        puts "---"
        puts entries.join("\n")
        T.write_file(entries)
        puts "Total: #{sum}"
    end
else
    sum = 0
    File.open("#{ENV["HOME"]}/.t", "r").each_line do |line|
        worked = T.parse_timespan(line)
        if worked
            puts "#{worked} (#{worked.time_worked()})" 
            sum += worked.time_worked().total_hours
        end
    end
    puts "Total: #{sum}"
end
