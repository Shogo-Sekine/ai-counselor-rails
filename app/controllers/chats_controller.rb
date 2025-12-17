# frozen_string_literal: true

class ChatsController < ApplicationController
  # GET /chats
  # チャット画面を表示
  def index
  end

  # POST /chats
  # AIとの会話を処理
  def create
    user_message = params[:message]

    if user_message.blank?
      render json: { error: "メッセージを入力してください" }, status: :bad_request
      return
    end

    begin
      # AI APIを呼び出して応答を取得
      ai_response = AiClientService.generate(user_message)
      
      render json: { 
        user_message: user_message,
        ai_response: ai_response 
      }
    rescue AiClientService::TimeoutError => e
      render json: { error: e.message }, status: :request_timeout
    rescue AiClientService::ApiError => e
      render json: { error: e.message }, status: :service_unavailable
    rescue StandardError => e
      Rails.logger.error("Unexpected error in ChatsController: #{e.class} - #{e.message}")
      render json: { error: "予期しないエラーが発生しました" }, status: :internal_server_error
    end
  end
end
