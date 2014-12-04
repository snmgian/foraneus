add_to_load_path = lambda { |path|
  unless $LOAD_PATH.include?(path)
    $LOAD_PATH << path
  end
}

if __FILE__ == $0
  add_to_load_path.call(File.join(File.dirname(__FILE__), '..'))
  add_to_load_path.call(File.dirname(__FILE__))
  add_to_load_path.call(File.join(File.dirname(__FILE__), '../lib'))

  test_cases_pattern = File.join(File.dirname(__FILE__), '**/*_spec.rb')
  Dir.glob(test_cases_pattern).each { |file| require file}
end
