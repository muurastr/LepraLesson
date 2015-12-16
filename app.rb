#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db = SQLite3::Database.new 'lepra.db'
  @db.results_as_hash = true
end

# before вызывается каждый раз при перезагрузке любой страницы
before do
    init_db 
    # инициализация БД
end

# configure вызывается каждый раз при конфигурации приложения:
# когда изменился код программы И перезаерузилась страница
configure do
  init_db
  # инициализация БД
  @db.execute 'Create table if not exists Posts
  (
      id integer primary key autoincrement,
      created_date date,
      content text
    )'
end

get '/' do
  # выбираем список постов из БД (здест в обратном порядке)
  @results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

# обзаботчик get-запроса /new
# (браузер получает страницу с сервера)
get '/new' do
  erb :new 
end

# обработчик post-запроса /new
# (браузер отправляет данные на сервер)
post '/new' do
  # получаем переменную из post-запроса 
  content = params[:content]

# проверка на пустоту
  if content.length <= 0
    @error = 'Type post text'
    return erb :new
  end

# запись в таблицу введенного поста
  @db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

#перенаправление на главную станицу
  redirect to '/'
end

#вывод информации о посте
#универсвльный обработчик для всех страниц details/n
get '/details/:post_id' do
  #получаем переменную post_id из url /details/:post_id
  post_id = params[:post_id]
  #получаем список постов (у нас тут будет тлько один пост)
  results = @db.execute 'select * from Posts where id = ?', [post_id]
  #выбираем этот один пост в переменную @row- строка с индексом 0
  @row = results[0]
  #возвращаем представление details.erb
  erb :details
end

#обработчик post-запроса /details/..
#(браузер отправляет данные на сервер, мы их принимаем)
post '/details/:post_id' do
  #получаем переменную post_id из url /details/:post_id
  post_id = params[:post_id]
  #получаем содержимое нашего комментария
  # = переменную из post-запроса 
  content = params[:content]
  erb "You typed comment #{content} for post #{post_id}"
end
