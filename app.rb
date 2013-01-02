require 'builder'
require 'rack/rpc'

class Server < Rack::RPC::Server
  def supported_methods(arg1)
    # Give an endpoint for authentication purposes
    'metaWeblog.getRecentPosts'
  end
  rpc 'mt.supportedMethods' => :supported_methods

  def recent_posts(blog_id, username, password, number_of_posts)
    # Return nothing so we never trigger
    '<array><data></data></array>'
  end
  rpc 'metaWeblog.getRecentPosts' => :recent_posts

  def new_post(blog_id, user, password, content, publish)
    # Webhook
    puts content['title']
    puts content['description']
    puts content['categories']
    puts content['mt_keywords'][0]
    puts content['post_status']
    '<string>200</string>'
  end
  rpc 'metaWeblog.newPost' => :new_post
end
