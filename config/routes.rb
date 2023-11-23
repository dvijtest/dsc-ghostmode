DiscourseShadowbanTopicView::Engine.routes.draw do
    put "/enable" => "hide_posts#enable"
    put "/disable" => "hide_posts#disable"
  end
  