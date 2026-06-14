module ApplicationHelper
  # 名前の頭文字（アバター用）
  def avatar_initial(user)
    source = user.display_name.presence || user.handle
    source.to_s.gsub(/[^[:alnum:]]/, "").first&.upcase || "?"
  end

  # ハンドル名から決まる、安定したインク色のグラデーション
  def avatar_gradient(user)
    palettes = [
      ["#3A4FB8", "#6C7BE0"], # indigo ink
      ["#0E7C66", "#3FB89A"], # viridian
      ["#B83A6B", "#E06C97"], # wine rose
      ["#B8763A", "#E0A56C"], # sepia
      ["#5A3AB8", "#8E6CE0"], # violet
      ["#2F6FB8", "#5FA0E0"], # cobalt
      ["#B83A3A", "#E06C6C"], # vermilion
    ]
    idx = user.handle.to_s.each_byte.sum % palettes.length
    from, to = palettes[idx]
    "background: linear-gradient(135deg, #{from}, #{to});"
  end

  # アバター（丸い頭文字バッジ）
  def user_avatar(user, size: 44)
    content_tag :span, avatar_initial(user),
                class: "avatar",
                style: "#{avatar_gradient(user)} width:#{size}px;height:#{size}px;font-size:#{(size * 0.42).round}px;",
                aria: { hidden: true }
  end

  # ハート（いいね）アイコン
  def heart_icon
    raw <<~SVG
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 21s-7.5-4.7-10-9.3C.7 9 1.6 5.6 4.6 4.7c2-.6 3.9.3 5 1.9 1.1-1.6 3-2.5 5-1.9 3 .9 3.9 4.3 2.6 7C19.5 16.3 12 21 12 21z"/></svg>
    SVG
  end

  # コメント（吹き出し）アイコン
  def comment_icon
    raw <<~SVG
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 11.5a8 8 0 0 1-11.6 7.2L3 21l2.3-6.4A8 8 0 1 1 21 11.5z"/></svg>
    SVG
  end

  # Twitter風の相対時刻（〇分前 / 〇時間前 / 日付）
  def time_ago_label(time)
    return "" unless time
    diff = Time.current - time
    case diff
    when 0...60       then "たった今"
    when 60...3600    then "#{(diff / 60).floor}分前"
    when 3600...86400 then "#{(diff / 3600).floor}時間前"
    when 86400...604800 then "#{(diff / 86400).floor}日前"
    else time.strftime("%Y年%-m月%-d日")
    end
  end
end
