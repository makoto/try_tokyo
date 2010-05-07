require 'rubygems'
require 'sinatra'
require 'json'
require 'tokyo_tyrant'
require 'uuid'

def db
  @db ||= TokyoTyrant::DB.new('127.0.0.1', 1978)
end

enable :sessions

def user_scope
  session['uuid'] ||= UUID.generate
end

def scoped_key(key)
  user_scope + '.' + key
end

get '/' do
  send_file 'public/index.html'
end

# mput
post '/insert' do
  json = JSON.parse(params['doc'])
  new_json = {}
  json.each{|key, value|
    new_json[scoped_key(key)] = value
  }
  db.mput(new_json)
end

# out
post '/remove' do
  key = JSON.parse(params['doc']).values.first
  db.delete(scoped_key(key))
end

# mget, get
post '/find' do
  # raise params.inspect
  keys  = JSON.parse(params['query']).keys
  cursor = [] 
  unless keys.empty?
    db.mget(keys.map{|key| scoped_key(key)}).each do |k, v|
      cursor << {k.sub(/^#{user_scope}\./, '') => v}
    end
  else
    # db.each do  |key, value|
    #   next unless key.match(user_scope)
    #   cursor << {key.sub(/^#{user_scope}\./, '') => value}
    # end
  end

  return JSON.generate(cursor)
end
