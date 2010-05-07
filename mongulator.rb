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
  user_scope + '.' + key
end

get '/' do
  send_file 'public/index.html'
end

# mput
post '/insert' do
  # db = scoped_database(params['name'])
  # if coll.count < 200
    json = JSON.parse(params['doc'])
    new_json = {}
    json.each{|key, value|
      new_json[scoped_key(key)] = value
    }
    db.mput(new_json)
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

# out
post '/remove' do
  key = JSON.parse(params['doc']).values.first
  db.delete(key)
end

# mget, get
post '/find' do
  # coll   = scoped_collection(params['name'])
  # coll   = scoped_collection(params['name'])
  keys  = JSON.parse(params['query']).keys
  # raise keys.inspect
  
  # fields = JSON.parse(params['fields'])
  # fields = nil if fields == {}
  # limit  = params['limit'].to_i
  # skip   = params['skip'].to_i
  # cursor = coll.find(query, :fields => fields, :limit => limit, :skip => skip)
  cursor = [] 
  unless keys.empty?
    # raise keys.inspect
    cursor << db.mget(keys.map{|key| scoped_key(key)})
  else
    db.each do  |key, value|
      if key.match(user_scope)
        cursor << {key.sub(/^#{user_scope}\./, '') => value}
      end
    end
  end
  # raise cursor.inspect
  return JSON.generate(cursor)
end
