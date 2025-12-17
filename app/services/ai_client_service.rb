# frozen_string_literal: true

# AI APIクライアントサービス
# 既存のFlask APIと通信してテキスト生成を行う
class AiClientService
  class ApiError < StandardError; end
  class TimeoutError < StandardError; end

  # AI APIのエンドポイントURL
  # 環境変数から取得、デフォルトはlocalhostの5000ポート
  AI_API_URL = ENV.fetch("AI_API_URL", "http://localhost:5000/generate")
  
  # タイムアウト設定(秒)
  TIMEOUT = 30

  # テキストを生成する
  # @param text [String] ユーザーの入力テキスト
  # @return [String] AIが生成した応答テキスト
  # @raise [ApiError] API呼び出しに失敗した場合
  # @raise [TimeoutError] タイムアウトした場合
  def self.generate(text)
    new.generate(text)
  end

  def generate(text)
    raise ArgumentError, "text cannot be blank" if text.blank?

    Rails.logger.info("AI API Request: #{text}")

    response = HTTParty.post(
      AI_API_URL,
      body: { text: text }.to_json,
      headers: { "Content-Type" => "application/json" },
      timeout: TIMEOUT
    )

    handle_response(response)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("AI API Timeout: #{e.message}")
    raise TimeoutError, "AI APIがタイムアウトしました"
  rescue StandardError => e
    Rails.logger.error("AI API Error: #{e.class} - #{e.message}")
    raise ApiError, "AI APIとの通信に失敗しました: #{e.message}"
  end

  private

  def handle_response(response)
    case response.code
    when 200
      result = JSON.parse(response.body)
      ai_response = result["response"]
      Rails.logger.info("AI API Response: #{ai_response}")
      ai_response
    when 400
      raise ApiError, "不正なリクエストです"
    when 500
      raise ApiError, "AI APIでエラーが発生しました"
    else
      raise ApiError, "予期しないレスポンス: #{response.code}"
    end
  rescue JSON::ParserError => e
    Rails.logger.error("JSON Parse Error: #{e.message}")
    raise ApiError, "レスポンスの解析に失敗しました"
  end
end
