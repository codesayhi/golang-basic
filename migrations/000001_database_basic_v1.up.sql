-- 1. Bảng Users
CREATE TABLE users (
                       id uuid NOT NULL,
                       name varchar(255) NOT NULL,
                       email varchar(255) NOT NULL,
                       avatar varchar(255) NOT NULL,
                       role varchar(255) NOT NULL DEFAULT 'user',
                       email_verified_at timestamp without time zone NULL,
                       password_hash varchar(255) NOT NULL,
                       remember_token varchar(100) NULL,
                       created_at timestamp without time zone NULL,
                       updated_at timestamp without time zone NULL,
                       deleted_at timestamp without time zone NULL,
                       CONSTRAINT users_pkey PRIMARY KEY (id),
                       CONSTRAINT users_email_unique UNIQUE (email),
                       CONSTRAINT users_role_check CHECK (role IN ('admin', 'user'))
);

------------------------------------------------------------------------------------------------------------------------

-- 2. Bảng countries
CREATE TABLE countries (
                           id uuid NOT NULL,
                           name varchar(255) NOT NULL,
                           slug varchar(255) NOT NULL,
                           code varchar(50) NOT NULL,
                           position integer NOT NULL DEFAULT 1,
                           deleted_at timestamp without time zone NULL,
                           created_at timestamp without time zone NULL,
                           updated_at timestamp without time zone NULL,
                           CONSTRAINT countries_pkey PRIMARY KEY (id),
                           CONSTRAINT countries_slug_unique UNIQUE (slug)
);

------------------------------------------------------------------------------------------------------------------------

-- 3. Bảng genres
CREATE TABLE genres (
                        id uuid NOT NULL,
                        name varchar(255) NOT NULL,
                        slug varchar(255) NOT NULL,
                        position integer NOT NULL DEFAULT 0,
                        created_at timestamp without time zone NULL,
                        updated_at timestamp without time zone NULL,
                        CONSTRAINT genres_pkey PRIMARY KEY (id),
                        CONSTRAINT genres_slug_unique UNIQUE (slug)
);


------------------------------------------------------------------------------------------------------------------------

-- 4. Bảng studios
CREATE TABLE studios (
                         id uuid NOT NULL,
                         name varchar(255) NOT NULL,
                         slug varchar(255) NOT NULL,
                         logo_url varchar(255) NULL,
                         description text NULL,
                         country_id uuid NULL,
                         founded_year integer NULL,
                         website varchar(255) NULL,
                         created_at timestamp without time zone NULL,
                         updated_at timestamp without time zone NULL,
                         CONSTRAINT studios_pkey PRIMARY KEY (id),
                         CONSTRAINT studios_slug_unique UNIQUE (slug),
                         CONSTRAINT studios_country_id_fk
                             FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE SET NULL
);


CREATE INDEX studios_country_id_idx ON studios(country_id);

------------------------------------------------------------------------------------------------------------------------


-- 5. Bảng movies
CREATE TABLE movies (
                        id uuid NOT NULL,
                        title varchar(255) NOT NULL,
                        slug varchar(255) NOT NULL,
                        description text NULL,
                        status varchar(255) NOT NULL DEFAULT 'ongoing',
                        release_year integer NULL,
                        country_id uuid NULL,
                        is_series boolean NOT NULL DEFAULT false,
                        total_episodes integer NULL,
                        poster_url varchar(255) NULL,
                        thumbnail_url varchar(255) NULL,
                        trailer_url varchar(255) NULL,
                        views bigint NOT NULL DEFAULT 0,
                        priority integer NOT NULL DEFAULT 0,
                        created_at timestamp without time zone NULL,
                        updated_at timestamp without time zone NULL,

                        CONSTRAINT movies_pkey PRIMARY KEY (id),
                        CONSTRAINT movies_slug_unique UNIQUE (slug),
                        CONSTRAINT movies_status_check CHECK (status IN ('ongoing','completed','upcoming','cancelled','paused')),
                        CONSTRAINT movies_country_id_fk
                        FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX movies_slug_idx ON movies(slug);
CREATE INDEX movies_status_idx ON movies(status);
CREATE INDEX movies_release_year_idx ON movies(release_year);
CREATE INDEX movies_is_series_idx ON movies(is_series);
CREATE INDEX movies_country_id_idx ON movies(country_id);
CREATE INDEX movies_priority_idx ON movies(priority);


------------------------------------------------------------------------------------------------------------------------

CREATE TABLE movie_genre (
                             movie_id uuid NOT NULL,
                             genre_id uuid NOT NULL,

                             CONSTRAINT movie_genre_pkey PRIMARY KEY (movie_id, genre_id),

                             CONSTRAINT movie_genre_movie_id_fk
                                 FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,

                             CONSTRAINT movie_genre_genre_id_fk
                                 FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
);

-- Tối ưu query theo genre -> lấy danh sách movie
CREATE INDEX movie_genre_genre_id_movie_id_idx ON movie_genre (genre_id, movie_id);


------------------------------------------------------------------------------------------------------------------------

CREATE TABLE episodes (
                          id uuid NOT NULL,
                          movie_id uuid NOT NULL,
                          title varchar(255) NOT NULL,
                          episode_no integer NOT NULL DEFAULT 1,
                          video_url text NOT NULL,
                          duration integer NULL, -- seconds
                          created_at timestamp without time zone NULL,
                          updated_at timestamp without time zone NULL,

                          CONSTRAINT episodes_pkey PRIMARY KEY (id),

                          CONSTRAINT episodes_movie_id_fk
                              FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- Tối ưu load tập theo phim + số thứ tự (đúng như migration)
CREATE INDEX episodes_movie_id_episode_no_idx ON episodes(movie_id, episode_no);

-- (Khuyến nghị tối ưu thêm) thường tập trong 1 phim không nên trùng số
CREATE UNIQUE INDEX episodes_movie_id_episode_no_unique ON episodes(movie_id, episode_no);


------------------------------------------------------------------------------------------------------------------------

CREATE TABLE episode_releases (
                                  id uuid NOT NULL,
                                  episode_id uuid NOT NULL,
                                  release_at timestamp without time zone NOT NULL,
                                  is_published boolean NOT NULL DEFAULT false,
                                  note varchar(255) NULL,

                                  CONSTRAINT episode_releases_pkey PRIMARY KEY (id),

                                  CONSTRAINT episode_releases_episode_id_fk
                                  FOREIGN KEY (episode_id) REFERENCES episodes(id) ON DELETE CASCADE
);

-- Tối ưu các query hay gặp: lấy lịch phát theo episode, lọc publish, sắp xếp theo thời gian
CREATE INDEX episode_releases_episode_id_release_at_idx ON episode_releases (episode_id, release_at);
CREATE INDEX episode_releases_is_published_release_at_idx ON episode_releases (is_published, release_at);

-- (Khuyến nghị mạnh) nếu 1 episode chỉ có 1 lịch phát duy nhất:
CREATE UNIQUE INDEX episode_releases_episode_id_unique ON episode_releases (episode_id);

------------------------------------------------------------------------------------------------------------------------

CREATE TABLE schedules (
                           id uuid NOT NULL,
                           movie_id uuid NOT NULL,
                           weekday smallint NOT NULL,                      -- 0..6
                           time time without time zone NOT NULL,           -- VD 20:00:00
                           release_at timestamp without time zone NULL,    -- countdown
                           order_in_day integer NOT NULL DEFAULT 0,
                           note varchar(255) NULL,
                           created_at timestamp without time zone NULL,
                           updated_at timestamp without time zone NULL,

                           CONSTRAINT schedules_pkey PRIMARY KEY (id),

                           CONSTRAINT schedules_movie_id_fk
                               FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,

                           CONSTRAINT schedules_weekday_check CHECK (weekday BETWEEN 0 AND 6)
);

-- Indexes tối ưu
CREATE INDEX schedules_movie_id_idx ON schedules (movie_id);
CREATE INDEX schedules_weekday_idx ON schedules (weekday);
CREATE INDEX schedules_release_at_idx ON schedules (release_at);

-- (Khuyến nghị) query lịch theo ngày thường đi kèm giờ
CREATE INDEX schedules_weekday_time_idx ON schedules (weekday, time);

-- (Khuyến nghị) query lịch theo phim + ngày + giờ
CREATE INDEX schedules_movie_id_weekday_time_idx ON schedules (movie_id, weekday, time);

-- (Tuỳ chọn) nếu mỗi phim không được trùng lịch cùng ngày+giờ
-- CREATE UNIQUE INDEX schedules_movie_weekday_time_unique ON schedules (movie_id, weekday, time);


------------------------------------------------------------------------------------------------------------------------

CREATE TABLE ratings (
                         id uuid NOT NULL,
                         movie_id uuid NOT NULL,
                         user_id uuid NOT NULL,
                         rating smallint NOT NULL, -- 1..5
                         comment text NULL,
                         created_at timestamp without time zone NULL,
                         updated_at timestamp without time zone NULL,

                         CONSTRAINT ratings_pkey PRIMARY KEY (id),

                         CONSTRAINT ratings_movie_id_fk
                             FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,

                         CONSTRAINT ratings_user_id_fk
                             FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

                         CONSTRAINT ratings_rating_check CHECK (rating BETWEEN 1 AND 5)
);

-- Tối ưu lọc/tính toán theo movie/user
CREATE INDEX ratings_movie_id_idx ON ratings(movie_id);
CREATE INDEX ratings_user_id_idx ON ratings(user_id);

-- (Khuyến nghị mạnh) 1 user chỉ được rate 1 lần / 1 movie
CREATE UNIQUE INDEX ratings_movie_user_unique ON ratings(movie_id, user_id);

------------------------------------------------------------------------------------------------------------------------

CREATE TABLE comments (
                          id uuid NOT NULL,
                          movie_id uuid NOT NULL,
                          user_id uuid NOT NULL,
                          content text NOT NULL,
                          parent_id uuid NULL,
                          created_at timestamp without time zone NULL,
                          updated_at timestamp without time zone NULL,

                          CONSTRAINT comments_pkey PRIMARY KEY (id),

                          CONSTRAINT comments_movie_id_fk
                              FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,

                          CONSTRAINT comments_user_id_fk
                              FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

                          CONSTRAINT comments_parent_id_fk
                              FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE
);

-- Indexes tối ưu truy vấn theo phim, theo user, theo thread
CREATE INDEX comments_movie_id_idx ON comments(movie_id);
CREATE INDEX comments_user_id_idx ON comments(user_id);
CREATE INDEX comments_parent_id_idx ON comments(parent_id);

-- (Khuyến nghị) hay dùng để load comment theo phim theo thời gian
CREATE INDEX comments_movie_id_created_at_idx ON comments(movie_id, created_at);


------------------------------------------------------------------------------------------------------------------------


CREATE TABLE watch_history (
                               id uuid NOT NULL,
                               user_id uuid NOT NULL,
                               movie_id uuid NOT NULL,
                               episode_id uuid NULL,
                               last_position integer NOT NULL DEFAULT 0, -- seconds
                               updated_at timestamp without time zone NULL,

                               CONSTRAINT watch_history_pkey PRIMARY KEY (id),

                               CONSTRAINT watch_history_user_id_fk
                                   FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

                               CONSTRAINT watch_history_movie_id_fk
                                   FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,

                               CONSTRAINT watch_history_episode_id_fk
                                   FOREIGN KEY (episode_id) REFERENCES episodes(id) ON DELETE SET NULL
);

-- Indexes tối ưu
CREATE INDEX watch_history_user_id_movie_id_idx ON watch_history (user_id, movie_id);
CREATE INDEX watch_history_episode_id_idx ON watch_history (episode_id);

-- (Khuyến nghị mạnh) mỗi user chỉ có 1 dòng history cho mỗi movie (và episode nếu bạn muốn tách theo tập)
-- Nếu lịch sử lưu theo movie (kể cả có episode_id), dùng unique dưới:
CREATE UNIQUE INDEX watch_history_user_movie_unique ON watch_history (user_id, movie_id);

-- (Tuỳ chọn) nếu bạn muốn lưu lịch sử theo từng tập (mỗi user mỗi episode 1 dòng) thì dùng cái này thay cho unique trên:
-- CREATE UNIQUE INDEX watch_history_user_episode_unique ON watch_history (user_id, episode_id);

------------------------------------------------------------------------------------------------------------------------


CREATE TABLE favorites (
                           user_id uuid NOT NULL,
                           movie_id uuid NOT NULL,
                           created_at timestamp without time zone NULL,
                           updated_at timestamp without time zone NULL,

                           CONSTRAINT favorites_pkey PRIMARY KEY (user_id, movie_id),

                           CONSTRAINT favorites_user_id_fk
                               FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

                           CONSTRAINT favorites_movie_id_fk
                               FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- Tối ưu query ngược: lấy danh sách user đã favorite 1 movie (hoặc thống kê theo movie)
CREATE INDEX favorites_movie_id_user_id_idx ON favorites (movie_id, user_id);


------------------------------------------------------------------------------------------------------------------------


CREATE TABLE playlists (
                           id uuid NOT NULL,
                           user_id uuid NOT NULL,
                           name varchar(255) NOT NULL,
                           is_public boolean NOT NULL DEFAULT false,
                           created_at timestamp without time zone NULL,
                           updated_at timestamp without time zone NULL,

                           CONSTRAINT playlists_pkey PRIMARY KEY (id),

                           CONSTRAINT playlists_user_id_fk
                               FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tối ưu: list playlist theo user
CREATE INDEX playlists_user_id_idx ON playlists(user_id);

-- (Khuyến nghị) nếu bạn hay filter theo public/explore
CREATE INDEX playlists_is_public_idx ON playlists(is_public);
CREATE INDEX playlists_is_public_created_at_idx ON playlists(is_public, created_at);


------------------------------------------------------------------------------------------------------------------------


CREATE TABLE playlist_movie (
                                playlist_id uuid NOT NULL,
                                movie_id uuid NOT NULL,
                                position integer NOT NULL DEFAULT 0,

                                CONSTRAINT playlist_movie_pkey PRIMARY KEY (playlist_id, movie_id),

                                CONSTRAINT playlist_movie_playlist_id_fk
                                    FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,

                                CONSTRAINT playlist_movie_movie_id_fk
                                    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- Tối ưu: load movies trong playlist theo thứ tự
CREATE INDEX playlist_movie_playlist_position_idx ON playlist_movie (playlist_id, position);

-- Tối ưu query ngược: movie thuộc những playlist nào
CREATE INDEX playlist_movie_movie_id_playlist_id_idx ON playlist_movie (movie_id, playlist_id);


------------------------------------------------------------------------------------------------------------------------


CREATE TABLE tags (
                      id uuid NOT NULL,
                      name varchar(255) NOT NULL,
                      slug varchar(255) NOT NULL,
                      created_at timestamp without time zone NULL,
                      updated_at timestamp without time zone NULL,

                      CONSTRAINT tags_pkey PRIMARY KEY (id),
                      CONSTRAINT tags_slug_unique UNIQUE (slug)
);



------------------------------------------------------------------------------------------------------------------------


CREATE TABLE movie_tag (
                           movie_id uuid NOT NULL,
                           tag_id uuid NOT NULL,

                           CONSTRAINT movie_tag_pkey PRIMARY KEY (movie_id, tag_id),

                           CONSTRAINT movie_tag_movie_id_fk
                               FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,

                           CONSTRAINT movie_tag_tag_id_fk
                               FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Tối ưu query theo tag -> list movie
CREATE INDEX movie_tag_tag_id_movie_id_idx ON movie_tag (tag_id, movie_id);



------------------------------------------------------------------------------------------------------------------------


CREATE TABLE people (
                        id uuid NOT NULL,
                        name varchar(255) NOT NULL,
                        role varchar(255) NOT NULL,
                        avatar varchar(255) NULL,
                        bio text NULL,
                        created_at timestamp without time zone NULL,
                        updated_at timestamp without time zone NULL,

                        CONSTRAINT people_pkey PRIMARY KEY (id),
                        CONSTRAINT people_role_check CHECK (role IN ('actor','director'))
);

-- (Khuyến nghị) hay filter theo role
CREATE INDEX people_role_idx ON people(role);



------------------------------------------------------------------------------------------------------------------------


CREATE TABLE movie_people (
                              movie_id uuid NOT NULL,
                              person_id uuid NOT NULL,
                              role varchar(255) NOT NULL,

                              CONSTRAINT movie_people_pkey PRIMARY KEY (movie_id, person_id, role),

                              CONSTRAINT movie_people_movie_id_fk
                                  FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,

                              CONSTRAINT movie_people_person_id_fk
                                  FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE,

                              CONSTRAINT movie_people_role_check CHECK (role IN ('actor','director'))
);

-- Tối ưu query theo person -> list movie theo role
CREATE INDEX movie_people_person_id_role_movie_id_idx ON movie_people (person_id, role, movie_id);

-- (Tuỳ chọn) nếu hay lọc theo role trước rồi tới movie
-- CREATE INDEX movie_people_role_movie_id_idx ON movie_people (role, movie_id);



------------------------------------------------------------------------------------------------------------------------


CREATE TABLE menus (
                       id uuid NOT NULL,
                       name varchar(255) NOT NULL,
                       slug varchar(255) NULL,
                       type varchar(255) NOT NULL,
                       reference_id uuid NULL,                 -- polymorphic: genre/country/studio/tag...
                       parent_id uuid NULL,
                       url varchar(255) NULL,
                       position integer NOT NULL DEFAULT 0,
                       is_active boolean NOT NULL DEFAULT true,
                       created_at timestamp without time zone NULL,
                       updated_at timestamp without time zone NULL,

                       CONSTRAINT menus_pkey PRIMARY KEY (id),

                       CONSTRAINT menus_parent_id_fk
                           FOREIGN KEY (parent_id) REFERENCES menus(id) ON DELETE CASCADE,

                       CONSTRAINT menus_type_check
                           CHECK (type IN ('custom','genre','country','studio','link','tag'))
);

-- Index tối ưu cho menu tree + sắp xếp + lọc active
CREATE INDEX menus_parent_id_position_idx ON menus(parent_id, position);
CREATE INDEX menus_is_active_idx ON menus(is_active);

-- Index tối ưu lookup theo type/reference (ví dụ type=genre + reference_id=...)
CREATE INDEX menus_type_reference_id_idx ON menus(type, reference_id);

-- (Khuyến nghị) nếu bạn hay resolve theo slug
CREATE INDEX menus_slug_idx ON menus(slug);

-- (Tuỳ chọn) nếu slug phải unique trong cùng 1 parent:
-- CREATE UNIQUE INDEX menus_parent_slug_unique ON menus(parent_id, slug);



------------------------------------------------------------------------------------------------------------------------


CREATE TABLE ads (
                     id uuid NOT NULL,
                     image varchar(255) NOT NULL,
                     link varchar(255) NULL,
                     position varchar(255) NOT NULL,
                     "order" integer NOT NULL DEFAULT 0,
                     start_at timestamp without time zone NULL,
                     end_at timestamp without time zone NULL,
                     status boolean NOT NULL DEFAULT true,
                     created_at timestamp without time zone NULL,
                     updated_at timestamp without time zone NULL,

                     CONSTRAINT ads_pkey PRIMARY KEY (id),

                     CONSTRAINT ads_position_check CHECK (position IN ('header','sidebar','footer','player')),

    -- (Tuỳ chọn) đảm bảo khoảng thời gian hợp lệ khi cả 2 có giá trị
                     CONSTRAINT ads_time_range_check CHECK (start_at IS NULL OR end_at IS NULL OR start_at <= end_at)
);

-- Index tối ưu hiển thị ads theo vị trí + trạng thái + thời gian
CREATE INDEX ads_position_status_idx ON ads (position, status);
CREATE INDEX ads_status_start_end_idx ON ads (status, start_at, end_at);
CREATE INDEX ads_position_order_idx ON ads (position, "order");



------------------------------------------------------------------------------------------------------------------------


CREATE TABLE activity_logs (
                               id uuid NOT NULL,
                               user_id uuid NULL,
                               action varchar(255) NOT NULL,              -- create_movie, update_user, ...
                               data_before jsonb NULL,
                               data_after jsonb NULL,
                               created_at timestamp without time zone NULL,
                               updated_at timestamp without time zone NULL,

                               CONSTRAINT activity_logs_pkey PRIMARY KEY (id),

                               CONSTRAINT activity_logs_user_id_fk
                                   FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Tối ưu truy vấn log theo user và theo loại action
CREATE INDEX activity_logs_user_id_created_at_idx ON activity_logs (user_id, created_at);
CREATE INDEX activity_logs_action_created_at_idx ON activity_logs (action, created_at);

-- (Tuỳ chọn) nếu bạn hay search theo key trong jsonb:
CREATE INDEX activity_logs_data_after_gin_idx ON activity_logs USING GIN (data_after);
CREATE INDEX activity_logs_data_before_gin_idx ON activity_logs USING GIN (data_before);
