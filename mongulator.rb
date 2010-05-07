require 'rubygems'
require 'sinatra'
require 'json'
require 'tokyo_tyrant'

def db
  @db ||= TokyoTyrant::DB.new('127.0.0.1', 1978)
end

enable :sessions

def user_scope
  @env['REMOTE_ADDR']
end

def scoped_key(key)
  user_scope + '.' + name
end

get '/' do
  send_file 'public/index.html'
end

# mput
post '/insert' do
  # db = scoped_database(params['name'])
  # if coll.count < 200
    db.mput(JSON.parse(params['doc']))
  # end
end

# post '/update' do
#   coll   = scoped_collection(params['name'])
#   query  = JSON.parse(params['query'])
#   doc    = JSON.parse(params['doc'])
#   upsert = (params['upsert'] == 'true')
#   multi  = (params['multi'] == 'true')
#   coll.update(query, doc, :upsert => upsert, :multi => multi)
# end
# 
# post '/remove' do
#   coll = scoped_collection(params['name'])
#   coll.remove(JSON.parse(params['doc']))
# end

post '/find' do
  # coll   = scoped_collection(params['name'])
  # coll   = scoped_collection(params['name'])
  # query  = JSON.parse(params['query'])
  # fields = JSON.parse(params['fields'])
  # fields = nil if fields == {}
  # limit  = params['limit'].to_i
  # skip   = params['skip'].to_i
  # cursor = coll.find(query, :fields => fields, :limit => limit, :skip => skip)
  cursor = [] 
  db.each do  |key, value|
    cursor << {key => value}
  end
  return JSON.generate(cursor)
end
