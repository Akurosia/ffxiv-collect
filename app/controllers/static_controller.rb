class StaticController < ApplicationController
  def commands
    @oauth_url = 'https://discord.com/oauth2/authorize' \
      "?client_id=#{Rails.application.credentials.dig(:discord, :interactions_client_id)}" \
      '&scope=applications.commands'
  end

  def credits
    @developers = Character.where(id: [7660136]).order(:name)
    @sourcers = Character.where(id: [17928665, 4763007]).order(:name)
    @translators = Character.where(id: [17928665, 7547066, 8011032, 7944237, 5602002, 30220792, 3937654])
      .order(:name)
  end

  def faq
    @users = Redis.current.get('stats-users')
    @characters = Redis.current.get('stats-characters')
    @achievement_characters = Redis.current.get('stats-achievement-characters')
    @active_characters = Redis.current.get('stats-active-characters')
    @active_achievement_characters = Redis.current.get('stats-active-achievement-characters')
  end

  def home
  end

  def not_found
    flash[:error] = t('alerts.not_found')
    redirect_to root_path
  end
end
