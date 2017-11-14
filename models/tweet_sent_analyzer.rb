require_relative 'environment'

class TweetExtractor
  attr_reader :brand_name
  attr_reader :client

  def initialize(brand_name)
    @brand_name = brand_name
    @tweet_credentials = YAML::load_file('Config/tweeter.yml')
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key= @tweet_credentials[:consumer_key]
      config.consumer_secret = @tweet_credentials[:consumer_secret]
      config.access_token = @tweet_credentials[:access_token]
      config.access_token_secret = @tweet_credentials[:access_token_secret]
    end
  end

  def get_tweets
    extracted_tweets = client.search("#" + self.brand_name)
    extracted_tweets
  end
end

class SentimentExtractor
  attr_reader :analyzer
  attr_reader :tweets

  def initialize(tweets)
    @analyzer = Sentimental.new
    @analyzer.load_defaults
    @tweets = tweets
  end

  def measure_tweet_sentiment
    sent_list = []
    self.tweets.each do |tweet|
      text = tweet.full_text
      sentiment_score = self.analyzer.score text
      sentiment = self.analyzer.sentiment text
      sent_list << [text, sentiment_score, sentiment]
    end
    sent_list
  end
end

class SentimentAnalyzer
  attr_reader :sentiment_data
  attr_reader :df

  def initialize sentiment_data
    @sentiment_data = sentiment_data
    @df = Daru::DataFrame.rows(self.sentiment_data, order: [:tweet_text, :sentiment_score, :sentiment])
  end

  def get_number_of_positive_sentiments
     self.df[:sentiment].select{|s| s == :positive}.count
  end

  def get_number_of_negative_sentiments
    self.df[:sentiment].select{|s| s == :negative}.count
  end

  def get_number_of_neutral_sentiments
    self.df[:sentiment].select{|s| s == :neutral}.count
  end

  def get_positive_sentiments
    pos_sent = self.df[:sentiment].select{|s| s == :positive}
    positives = pos_sent.map{|x| [pos_sent.index(x), x]}
    positives.to_h
  end

  def get_negative_sentiments
    self.df[:sentiments].select{|s| s == :negative}
  end

  def get_number_of_tweets
    self.df[:tweet_text].count
  end
end
