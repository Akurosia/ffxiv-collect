class CharactersController < ApplicationController
  before_action :verify_signed_in!, only: [:verify, :validate, :destroy]
  before_action :confirm_unverified!, :set_code, only: [:verify, :validate]
  before_action :set_profile, only: [:show, :stats_recent, :stats_rarity]

  COLLECTIONS = %w(achievements mounts minions orchestrions spells emotes bardings hairstyles armoires).freeze

  def show
    unless @profile.public? || @profile.verified_user?(current_user)
      flash[:error] = "This character's profile has been set to private."
      redirect_back(fallback_location: root_path)
    end

    if @profile.stale? && !@profile.in_queue?
      @profile.sync
    end

    @triad = @profile.triple_triad
  end

  def stats_recent
    @collections = COLLECTIONS.each_with_object({}) do |collection, h|
      h[collection] = @profile.most_recent(collection)
    end
  end

  def stats_rarity
    @collections = COLLECTIONS.each_with_object({}) do |collection, h|
      h[collection] = @profile.most_rare(collection)
    end
  end

  def search
    @server, @name = params.values_at(:server, :name)
    @search = @server.present? && @name.present?

    if @search
      begin
        @characters = Character.search(@server, @name)
        if @characters.empty?
          flash.now[:alert] = 'No characters found.'
        end
      rescue XIVAPI::Errors::RequestError
        flash.now[:alert] = 'There was a problem contacting the Lodestone. Please try again later.'
      end
    else
      if user_signed_in?
        @characters = current_user.characters.order(:server, :name).to_a
          .sort_by { |character| character.verified_user_id == current_user.id ? 0 : 1 }
      end
    end
  end

  def select
    character = Character.find_by(id: params[:id]) || Character.fetch(params[:id])

    if !character.present?
      flash[:error] = 'There was a problem selecting that character.'
      redirect_back(fallback_location: root_path)
    elsif character.private?(current_user)
      flash[:alert] = "Sorry, this character's verified user has set their collections to private."
      redirect_back(fallback_location: root_path)
    else
      if params[:compare]
        cookies[:comparison] = params[:id]
      elsif user_signed_in?
        current_user.update(character_id: params[:id])
      else
        cookies[:character] = params[:id]
      end

      if user_signed_in?
        current_user.characters << character unless current_user.characters.exists?(character.id)
      end

      flash[:success] = "Your #{'comparison ' if params[:compare]}character has been set."
      redirect_to character_path(character)
    end
  end

  def forget
    if user_signed_in?
      current_user.update(character_id: nil)
    else
      cookies[:character] = nil
    end

    flash[:success] = 'You are no longer tracking a character.'
    redirect_to root_path
  end

  def forget_comparison
    cookies[:comparison] = nil
    redirect_back(fallback_location: root_path)
  end

  def destroy
    current_user.characters.delete(params[:id])
    redirect_to search_characters_path(({ compare: 1 } if params[:compare]))
  end

  def refresh
    if @character.in_queue?
      flash[:alert] = 'Your character has already been refreshed in the past 30 minutes. Please try again later.'
    else
      character = Character.fetch(@character.id)
      if character.present?
        character.update(queued_at: Time.now)
        flash[:success] = 'Your character has been refreshed.'
      else
        flash[:alert] = 'There was a problem contacting the Lodestone. Please try again later.'
      end
    end

    redirect_back(fallback_location: root_path)
  end

  def verify
    session[:return_to] = request.referer
  end

  def validate
    if @character.verify!(current_user)
      flash[:success] = 'Your character has been verified. You can now remove the code from your profile.'
      redirect_to_previous
    else
      flash[:alert] = 'Your character could not be verified. Please check your profile and try again.'
      render :verify
    end
  end

  private
  def set_code
    @code = @character.verification_code(current_user)
  end

  def set_profile
    @profile = Character.find(params[:id])
  end

  def confirm_unverified!
    if @character.verified_user?(current_user)
      flash[:alert] = 'Your character has already been verified.'
      redirect_to root_path
    end
  end
end
