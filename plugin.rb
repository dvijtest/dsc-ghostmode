# name: dsc-ghostmode
# about: Hide a user's posts from everybody else
# version: 0.0.15
# authors: dvijtest
enabled_site_setting :ghostmode_enabled

after_initialize do
  module ::DiscourseShadowbanTopicView
    def filter_post_types(posts)
      result = super(posts)
      if SiteSetting.ghostmode_show_to_staff && @user&.staff?
        result
      else
        # result.where(
        #  'posts.id NOT IN (?)',
        #   SiteSetting.ghostmode_posts.split('|')
        # )
        result.where(
          #'(posts.id NOT IN (?) OR posts.user_id = ?)',
          #'(posts.id NOT IN (?) OR posts.user_id IN (SELECT u.id FROM users u WHERE u.admin = ? OR u.id = ?))', #0.0.8
          '(posts.id NOT IN (?) OR posts.user_id IN (SELECT u.id FROM users u WHERE u.admin = ?) OR posts.user_id = ?)',
          SiteSetting.ghostmode_posts.split('|'),
          true,
          @user&.id || 0
        )
      end
    end
  end

  class ::TopicView
    prepend ::DiscourseShadowbanTopicView
  end

  module ::DiscourseShadowbanTopicQuery
    def default_results(options = {})
      result = super(options)
      if SiteSetting.ghostmode_show_to_staff && @user&.staff?
        result
      else
        #  result.where(
        #    'topics.id NOT IN (?)',
        #    SiteSetting.ghostmode_topics.split('|')
        #  )
        result.where(
          #'(topics.id NOT IN (?) OR topics.user_id = ?)',
          #'(topics.id NOT IN (?) OR topics.user_id IN (SELECT u.id FROM users u WHERE u.admin = ? OR u.id = ?))',  #0.0.8
          '(topics.id NOT IN (?) OR topics.user_id IN (SELECT u.id FROM users u WHERE u.admin = ?) OR topics.user_id = ?)',
          SiteSetting.ghostmode_topics.split('|'),
          true,
          @user&.id || 0
        )
      end
    end
  end

  class ::TopicQuery
    prepend ::DiscourseShadowbanTopicQuery
  end


  module ::DiscourseShadowbanPostAlerter
    def create_notification(user, type, post, opts = {})
      if (SiteSetting.ghostmode_show_to_staff && user&.staff?) || SiteSetting.ghostmode_posts.split('|').find_index(post.id).nil?
        super(user, type, post, opts)
      end
    end
  end

  class ::PostAlerter
    prepend ::DiscourseShadowbanPostAlerter
  end

  module ::DiscourseShadowbanPostCreator
    def update_topic_stats
      #return unless SiteSetting.ghostmode_topics.split('|').find_index(@post.id).nil? #0.0.11
      #super
      if SiteSetting.ghostmode_topics.split('|').find_index(@post.id).nil?
        super
      end
    end
  end

  class ::PostCreator
    prepend ::DiscourseShadowbanPostCreator
  end

end
