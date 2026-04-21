class EnableExtensions < ActiveRecord::Migration[7.1]
  def change
    enable_extension "pgcrypto"
    enable_extension "citext"
    enable_extension "btree_gist"
    enable_extension "pg_trgm"
  end
end
