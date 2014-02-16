class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do |t|
        t.string :task
        t.string :deadline
    end
  end
  def down
    drop_table :tasks
  end
end
