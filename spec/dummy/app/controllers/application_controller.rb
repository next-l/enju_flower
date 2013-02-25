class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied, :with => :render_403
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  before_filter :get_library_group, :set_locale, :set_available_languages

  enju_biblio
  enju_library

  private
  def render_403
    return if performed?
    if user_signed_in?
      respond_to do |format|
        format.html {render :template => 'page/403', :status => 403}
        format.xml {render :template => 'page/403', :status => 403}
        format.json
      end
    else
      respond_to do |format|
        format.html {redirect_to new_user_session_url}
        format.xml {render :template => 'page/403', :status => 403}
        format.json
      end
    end
  end

  def render_404
    return if performed?
    respond_to do |format|
      format.html {render :template => 'page/404', :status => 404}
      format.mobile {render :template => 'page/404', :status => 404}
      format.xml {render :template => 'page/404', :status => 404}
      format.json
    end
  end

  def access_denied
    raise CanCan::AccessDenied
  end

  def store_location
    if request.get? and request.format.try(:html?) and !request.xhr?
      session[:user_return_to] = request.fullpath
    end
  end

  def solr_commit
    Sunspot.commit
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, request.remote_ip)
  end

  def move_position(resource, direction, redirect = true)
    if ['higher', 'lower'].include?(direction)
      resource.send("move_#{direction}")
      if redirect
        redirect_to url_for(:controller => resource.class.to_s.pluralize.underscore)
        return
      end
    end
  end

  def set_role_query(user, search)
    role = user.try(:role) || Role.default_role
    search.build do
      with(:required_role_id).less_than_or_equal_to role.id
    end
  end

  def get_version
    @version = params[:version_id].to_i if params[:version_id]
    @version = nil if @version == 0
  end

  def convert_charset
    case params[:format]
    when 'csv'
      return unless Setting.csv_charset_conversion
      # TODO: 他の言語
      if @locale.to_sym == :ja
        headers["Content-Type"] = "text/csv; charset=Shift_JIS"
        response.body = NKF::nkf('-Ws', response.body)
      end
    when 'xml'
      if @locale.to_sym == :ja
        headers["Content-Type"] = "application/xml; charset=Shift_JIS"
        response.body = NKF::nkf('-Ws', response.body)
      end
    end
  end

  def make_internal_query(search)
    # 内部的なクエリ
    set_role_query(current_user, search)

    unless params[:mode] == "add"
      expression = @expression
      patron = @patron
      manifestation = @manifestation
      reservable = @reservable
      carrier_type = params[:carrier_type]
      library = params[:library]
      language = params[:language]
      if defined?(EnjuSubject)
        subject = params[:subject]
        subject_by_term = Subject.where(:term => params[:subject]).first
        @subject_by_term = subject_by_term
      end

      search.build do
        with(:publisher_ids).equal_to patron.id if patron
        with(:original_manifestation_ids).equal_to manifestation.id if manifestation
        with(:reservable).equal_to reservable unless reservable.nil?
        unless carrier_type.blank?
          with(:carrier_type).equal_to carrier_type
        end
        unless library.blank?
          library_list = library.split.uniq
          library_list.each do |library|
            with(:library).equal_to library
          end
        end
        unless language.blank?
          language_list = language.split.uniq
          language_list.each do |language|
            with(:language).equal_to language
          end
        end
        if defined?(EnjuSubject)
          unless subject.blank?
            with(:subject).equal_to subject_by_term.term
          end
        end
      end
    end
    return search
  end

  def solr_commit
    Sunspot.commit
  end

  def clear_search_sessions
    session[:query] = nil
    session[:params] = nil
    session[:search_params] = nil
    session[:manifestation_ids] = nil
  end

  def set_locale
    if params[:locale]
      unless I18n.available_locales.include?(params[:locale].to_s.intern)
        raise InvalidLocaleError
      end
    end
    if user_signed_in?
      locale = params[:locale] || session[:locale] || current_user.locale.try(:to_sym)
    else
      locale = params[:locale] || session[:locale]
    end
    if locale
      I18n.locale = @locale = session[:locale] = locale.to_sym
    else
      I18n.locale = @locale = session[:locale] = I18n.default_locale
    end
  rescue InvalidLocaleError
    @locale = I18n.default_locale
  end

  def set_available_languages
    if Rails.env == 'production'
      @available_languages = Rails.cache.fetch('available_languages'){
        Language.where(:iso_639_1 => I18n.available_locales.map{|l| l.to_s}).select([:id, :iso_639_1, :name, :native_name, :display_name, :position]).all
      }
    else
      @available_languages = Language.where(:iso_639_1 => I18n.available_locales.map{|l| l.to_s})
    end
  end
end
