# frozen_string_literal: true

module DiscourseShadowbanTopicView
    class HidePostsController < ApplicationController
      requires_login
  
      def enable
        #t = Topic.find(params[:id])
        t = Posts.find(params[:id])
        if current_user.staff?
          t.custom_fields['hide_posts'] = true
          t.save!
          render json: { ghostmode_enabled: true }
        else
          render json: { failed: 'Access denied' }, status: 403
        end
      end
  
      def disable
        #t = Topic.find(params[:id])
        t = Posts.find(params[:id])
        if current_user.staff?
          t.custom_fields['hide_posts'] = false
          t.save!
          render json: { ghostmode_enabled: false }
        else
          render json: { failed: 'Access denied' }, status: 403
        end
      end
    end
  end
  
  