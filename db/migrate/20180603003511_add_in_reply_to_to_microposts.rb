class AddInReplyToToMicroposts < ActiveRecord::Migration[5.1]
  def change
    add_column :microposts, :in_reply_to, :Integer, default: 0
  end
end
