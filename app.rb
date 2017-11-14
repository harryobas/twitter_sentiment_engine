require 'sinatra'
require_relative 'models/tweet_sent_analyzer'

require 'sinatra/reloader' if development?


enable :run, :sessions

get '/' do
  erb :home
end

post '/sentiment' do
  redirect to("/sentiment/#{params[:entity]}")
end

get '/sentiment/:name' do
  twt_ext = TweetExtractor.new params[:name]
  twts = twt_ext.get_tweets.take(100)
  @name = params[:name]
  @sentiment_data = SentimentExtractor.new(twts).measure_tweet_sentiment
  @analyzer = SentimentAnalyzer.new(@sentiment_data)
  erb :index
end

__END__
@@layout
<% title="Twitter Sentiment Analysis Platform" %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%= title %></title>
    <style>
table {
    font-family: arial, sans-serif;
    border-collapse: collapse;
    width: 100%;
}

td, th {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}

tr:nth-child(even) {
    background-color: #dddddd;
}
h1 {
color: #903;
font: 32px/1 Helvetica, Arial, sans-serif;

}
header h1 {
font-size: 40px;
line-height: 80px;
background: transparent url(/images/unnamed.png) 0 0 no-repeat;
padding-left: 82px;
}

p {
font: 13px/1.4 Helvetica, Arial, sans-serif;
}
</style>
  </head>
  <body>
    <header>
      <h1><%= title %></h1>
    </header>
    <div><%= yield %></div>
  </body>
</html>

@@index
<div></div>
<div><h3>Sentiment Analysis Report for <%= @name %></h3></div>
<div>
  <p>Generated: <%= Time.now.strftime("%-d %B %Y, %l:%M%P") %></p>
</div>
<div>
  <p>Number of Analyzed Tweets: <%= @analyzer.get_number_of_tweets %></p>
  <p>Positive Sentiments: <%= @analyzer.get_number_of_positive_sentiments %></p>
  <p>Negative Sentiments: <%= @analyzer.get_number_of_negative_sentiments %></p>
  <p>Neutral Sentiments: <%= @analyzer.get_number_of_neutral_sentiments %></p>
</div>
<div>
  <table>
    <tr>
      <th>Tweet</th>
      <th>Sentiment score</th>
      <th>Sentiment</th>
    </tr>
    <% @sentiment_data.each do |tw, sc, sent| %>
    <tr>
      <td><%=tw%></td>
      <td><%=sc%></td>
      <td><%=sent%></td>
    </tr>
    <%end%>
  </table>
</div>

@@home
<center>
 <section>
  <div>
    <p>Welcome to the twitter sentiment analysis Platform. The one stop shop for analyzing sentiment of tweets</p>
  </div>
  <div>
    <h3>Please enter an entity name to analyze tweets sentiment</h3>
  </div>
  <div>
    <form action="/sentiment" method="post">
      <p>entity name: <input type="text" name="entity" value=""><input type="submit"</p>
    </form>
  </div>
</section>
</center>
