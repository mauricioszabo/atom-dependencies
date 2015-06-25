require 'ruby-prof'

# Include this on your spec_helper or any other test framework: after you loaded your rails
# environment, you create this class and run RubyProf.start. Then, after all tests had run, or
# after a bunch of tests had run, you use `profiler.aggregate` to aggregate the dependencies
# so far in your code.
#
# After all tests have run, you can run `profiler.generate_file` to save the JSON file.
class Profiler
  attr_reader :rails, :dependent_classes

  def initialize
    @rails = Dir.glob("app/**{,/*/**}/*.rb").flat_map do |x|
      name = x.gsub(/app\/.*?\/|\.rb/, '').camelize
      [name, "<Class::#{name}>"]
    end.to_set
    @rails << "ActionView::CompiledTemplates"
    @dependent_classes = {}

    ObjectSpace.each_object(ActiveRecord::Base.singleton_class) { |x| x.singleton_class.send(:define_method, :inspect) { to_s }}
  end

  def result
    result = RubyProf.stop

    def result.eliminate_methods(methods, matcher)
      eliminated = []
      i = 0
      while i < methods.size
        method_info = methods[i]
        method_name = method_info.full_name
        klass = method_name.gsub(/#.*/, '')
        if !(matcher.include?(klass)) && !method_info.root?
          eliminated << methods.delete_at(i)
          method_info.eliminate!
        else
          i += 1
        end
      end
      eliminated
    end
    result.eliminate_methods! [@rails]
    result
  end

  def name_for(method)
    name = method.full_name
    case name
    when /ActionView::CompiledTemplates/
      name.gsub(/.*?#/, '').gsub(/__[\d_]*$/, '').gsub(/_(html|erb|rhtml)/, '.\\1')
    when /\<Class::/
      name.gsub(/<Class::(.*?)>#/, '\\1.')
    else
      name
    end
  end

  def aggregate
    result.threads.each do |thread|
      thread.methods.each do |method|
        name = name_for(method)
        klass_name = name.gsub(/[#\.].*/, '')

        @dependent_classes[klass_name] ||= Set[]

        method.children.map do |c|
          child_name = name_for(c.target)
          @dependent_classes[klass_name] << child_name.gsub(/[#\.].*/, '')
        end
      end
    end
    RubyProf.start
  end

  def generate_file
    File.open('dependencies.json', 'w') do |f|
      f.print(dependent_classes.to_json)
    end
  end
end
