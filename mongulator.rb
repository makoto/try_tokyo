require 'rubygems'
require 'sinatra'
require 'json'
require 'tokyo_tyrant'
require 'uuid'

def tch
  TokyoTyrant::DB.new('127.0.0.1', 1978)
end

def tcb
  TokyoTyrant::BDB.new('127.0.0.1', 1979)
end

def db
  @db ||= self.send(params['name'].to_sym)
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
  hash = JSON.parse(params['doc'])
  db.mput(scoped_hash(hash))
end

post  '/putlist' do
  hash = JSON.parse(params['doc'])
  db.putlist(scoped_hash(hash))
end

def scoped_hash(hash)
  new_hash = {}
  hash.each{|key, value|
    new_hash[scoped_key(key)] = value
  }
  return new_hash
end

post  '/putdup' do
  raise "PUTLIST"
end

get  '/getlist' do
  raise "GETLIST"
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
