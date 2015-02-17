require 'rubygems'
require 'sinatra'
require 'chronic'
require 'maneki'
require 'moredown'
require 'erb'
require 'haml'

require 'models'
require 'helpers'


configure do
  set :static_cache_control, [:public, max_age: 1.year]
end


get '/' do
  @posts = Post.index || raise(Sinatra::NotFound)
  haml :index
end


get '/tags/:tag/?' do
  @tag = params[:tag]
  @posts = Post.find_tagged_with(@tag)
  haml :tag
end


get '/archive/?' do
  @posts_by_month_and_year = Post.archive
  haml :archive
end


get '/rss' do
  @posts = Post.index
  content_type 'application/rss+xml'
  erb :rss, layout: false
end


get '/sitemap.xml' do
  @posts = Post.all
  content_type 'text/xml'
  erb :sitemap, :layout => false
end


get '/media/:file.:ext' do
  filename = File.dirname(__FILE__) + '/posts/media/' + params[:file] + '.' + params[:ext]
  if File.file? filename
    cache_control :public, max_age: 1.week
    send_file(filename)
  else
    raise(Sinatra::NotFound)
  end
end


get '/:slug.text' do
  filename = File.dirname(__FILE__) + '/posts/' + params[:slug] + '.text'
  if File.file? filename
    content_type 'text/plain'
    File.open filename
  end
end


get '/:slug/?' do
  @post = Post.find(params[:slug])
  
  if @post
    cache_control :public, max_age: 1.week
    haml :post
  else
    @keyword = params[:slug].gsub('-', ' ')
    @posts = Post.search(@keyword)
    haml :search
  end
end


before do
  # Redirect to nathanhoad.net
  unless request.env['REMOTE_ADDR'] == '127.0.0.1'
    redirect "#{request.scheme}://nathanhoad.net" if request.host == 'www.nathanhoad.net'
  end
end


not_found do
  haml :not_found
end