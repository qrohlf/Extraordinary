class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do |t|
        t.timestamps
        t.string :task
        t.string :deadline
        t.string :status, default: 'needs_moderation'
    end
  end
  def down
    drop_table :tasks
  end
end
