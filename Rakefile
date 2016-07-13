# == Dependencies ==============================================================
require 'rake'
require 'yaml'
require 'fileutils'
require 'rbconfig'
require 'front_matter_parser'
# require 'mp3info'
require 'taglib'
require 'aws-sdk'


# == Configuration =============================================================

# Set "rake watch" as default task
task :default => :watch

# Load the configuration file
CONFIG = YAML.load_file("_config.yml")

# Get and parse the date
DATE = Time.now.strftime("%Y-%m-%d")
TIME = Time.now.strftime("%H:%M:%S")
POST_TIME = DATE + ' ' + TIME

# Directories
POSTS = "_posts"
DRAFTS = "_drafts"

# == Helpers ===================================================================

# Execute a system command
def execute(command)
  system "#{command}"
end

# Chech the title
def check_title(title)
  if title.nil? or title.empty?
    raise "Please add a title to your file."
  end
end

# Transform the filename and date to a slug
def transform_to_slug(title, extension)
  characters = /("|'|!|\?|:|\s\z)/
  whitespace = /\s/
  "#{title.gsub(characters,"").gsub(whitespace,"-").downcase}.#{extension}"
end

# Read the template file
def read_file(template)
  File.read(template)
end

# Save the file with the title in the YAML front matter
def write_file(content, title, directory, filename)
  parsed_content = "#{content.sub("title:", "title: \"#{title}\"")}"
  parsed_content = "#{parsed_content.sub("date:", "date: #{POST_TIME}")}"
  File.write("#{directory}/#{filename}", parsed_content)
  puts "#{filename} was created in '#{directory}'."
end

# Create the file with the slug and open the default editor
def create_file(directory, filename, content, title, editor)
  FileUtils.mkdir(directory) unless File.exists?(directory)
  if File.exists?("#{directory}/#{filename}")
    raise "The file already exists."
  else
    write_file(content, title, directory, filename)
    if editor && !editor.nil?
      sleep 1
      execute("#{editor} #{directory}/#{filename}")
    end
  end
end

# Get the "open" command
def open_command
  if RbConfig::CONFIG["host_os"] =~ /mswin|mingw/
    "start"
  elsif RbConfig::CONFIG["host_os"] =~ /darwin/
    "open"
  else
    "xdg-open"
  end
end

# == Tasks =====================================================================

# rake post["Title"]
desc "Create a post in _posts"
task :post, :title do |t, args|
  title = args[:title]
  template = CONFIG["post"]["template"]
  extension = CONFIG["post"]["extension"]
  editor = CONFIG["editor"]
  check_title(title)
  filename = "#{DATE}-#{transform_to_slug(title, extension)}"
  content = read_file(template)
  create_file(POSTS, filename, content, title, editor)
end

# rake build
desc "Build the site"
task :build do
  execute("jekyll build")
end

# rake preview
desc "Launch a preview of the site in the browser"
task :preview do
  port = CONFIG["port"]
  if port.nil? or port.empty?
    port = 4000
  end
  Thread.new do
    puts "Launching browser for preview..."
    sleep 1
    execute("#{open_command} http://localhost:#{port}/")
  end
  Rake::Task[:watch].invoke
end


desc 'populates id3 tags'
task :populate, :fmyfile do |t, args|
    parsed = FrontMatterParser.parse_file(args[:fmyfile])
    # open id3 tag

    frame_factory = TagLib::ID3v2::FrameFactory.instance
    frame_factory.default_text_encoding = TagLib::String::UTF8

    TagLib::MPEG::File.open("episodes/#{parsed.front_matter['audio']}") do |fileref|
        tag = fileref.id3v2_tag
        puts tag.title
        puts tag.artist
        puts tag.album
        puts tag.comment
        tag.title = parsed.front_matter['title']
        tag.artist = parsed.front_matter['author']
        tag.album = 'Подкаст из провинции'
        tag.comment = parsed.content
        fileref.save
    end  # File is automatically closed at block
end

desc 's3upload'
task :s3up, :fmyfile do |_t, args|
  Rake::Task["build"].invoke
  parsed = FrontMatterParser.parse_file(args[:fmyfile])
  puts "Going to upload _site/episodes/#{parsed.front_matter['audio']}"
  s3 = Aws::S3::Resource.new(region:'eu-west-1')
  # obj = s3.bucket('cityhawk.ru').object(key: parsed.front_matter['audio'].to_s)
  obj = s3.bucket('cityhawk.ru').object(parsed.front_matter['audio'].to_s)
  obj.upload_file("_site/episodes/#{parsed.front_matter['audio']}", {acl: 'public-read'})

  obj = s3.bucket('cityhawk.ru').object('feed.xml')
  obj.upload_file("_site/feed.xml", {acl: 'public-read'})
end


