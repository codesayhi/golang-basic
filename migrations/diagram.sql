CREATE TABLE users (
                       id uuid PRIMARY KEY,
                       name varchar(255) NOT NULL,
                       email varchar(255) NOT NULL UNIQUE,
                       avatar varchar(255) NOT NULL,
                       role varchar(32) NOT NULL,
                       email_verified_at timestamp NULL,
                       password_hash varchar(255) NOT NULL,
                       remember_token varchar(100) NULL,
                       created_at timestamp NULL,
                       updated_at timestamp NULL
);

CREATE TABLE countries (
                           id uuid PRIMARY KEY,
                           name varchar(255) NOT NULL,
                           slug varchar(255) NOT NULL UNIQUE,
                           code varchar(20) not
                           position int NOT NULL,
                           deleted_at timestamp NULL,
                           created_at timestamp NULL,
                           updated_at timestamp NULL
);

CREATE TABLE genres (
                        id uuid PRIMARY KEY,
                        name varchar(255) NOT NULL,
                        slug varchar(255) NOT NULL UNIQUE,
                        position int NOT NULL,
                        created_at timestamp NULL,
                        updated_at timestamp NULL
);

CREATE TABLE studios (
                         id uuid PRIMARY KEY,
                         name varchar(255) NOT NULL,
                         slug varchar(255) NOT NULL UNIQUE,
                         logo_url varchar(255) NULL,
                         description text NULL,
                         country_id uuid NULL,
                         founded_year int NULL,
                         website varchar(255) NULL,
                         created_at timestamp NULL,
                         updated_at timestamp NULL,
                         FOREIGN KEY (country_id) REFERENCES countries(id)
);

CREATE TABLE movies (
                        id uuid PRIMARY KEY,
                        title varchar(255) NOT NULL,
                        slug varchar(255) NOT NULL UNIQUE,
                        description text NULL,
                        status varchar(32) NOT NULL,
                        release_year int NULL,
                        country_id uuid NULL,
                        is_series boolean NOT NULL,
                        total_episodes int NULL,
                        poster_url varchar(255) NULL,
                        thumbnail_url varchar(255) NULL,
                        trailer_url varchar(255) NULL,
                        views bigint NOT NULL,
                        priority int NOT NULL,
                        created_at timestamp NULL,
                        updated_at timestamp NULL,
                        FOREIGN KEY (country_id) REFERENCES countries(id)
);

CREATE TABLE episodes (
                          id uuid PRIMARY KEY,
                          movie_id uuid NOT NULL,
                          title varchar(255) NOT NULL,
                          episode_no int NOT NULL,
                          video_url text NOT NULL,
                          duration int NULL,
                          created_at timestamp NULL,
                          updated_at timestamp NULL,
                          FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE TABLE episode_releases (
                                  id uuid PRIMARY KEY,
                                  episode_id uuid NOT NULL,
                                  release_at timestamp NOT NULL,
                                  is_published boolean NOT NULL,
                                  note varchar(255) NULL,
                                  FOREIGN KEY (episode_id) REFERENCES episodes(id)
);

CREATE TABLE schedules (
                           id uuid PRIMARY KEY,
                           movie_id uuid NOT NULL,
                           weekday smallint NOT NULL,
                           time time NOT NULL,
                           release_at timestamp NULL,
                           order_in_day int NOT NULL,
                           note varchar(255) NULL,
                           is_active boolean NOT NULL,
                           created_at timestamp NULL,
                           updated_at timestamp NULL,
                           FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE TABLE ratings (
                         id uuid PRIMARY KEY,
                         movie_id uuid NOT NULL,
                         user_id uuid NOT NULL,
                         rating smallint NOT NULL,
                         comment text NULL,
                         created_at timestamp NULL,
                         updated_at timestamp NULL,
                         FOREIGN KEY (movie_id) REFERENCES movies(id),
                         FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE comments (
                          id uuid PRIMARY KEY,
                          movie_id uuid NOT NULL,
                          user_id uuid NOT NULL,
                          content text NOT NULL,
                          parent_id uuid NULL,
                          created_at timestamp NULL,
                          updated_at timestamp NULL,
                          FOREIGN KEY (movie_id) REFERENCES movies(id),
                          FOREIGN KEY (user_id) REFERENCES users(id),
                          FOREIGN KEY (parent_id) REFERENCES comments(id)
);

CREATE TABLE watch_history (
                               id uuid PRIMARY KEY,
                               user_id uuid NOT NULL,
                               movie_id uuid NOT NULL,
                               episode_id uuid NULL,
                               last_position int NOT NULL,
                               updated_at timestamp NULL,
                               FOREIGN KEY (user_id) REFERENCES users(id),
                               FOREIGN KEY (movie_id) REFERENCES movies(id),
                               FOREIGN KEY (episode_id) REFERENCES episodes(id)
);

CREATE TABLE playlists (
                           id uuid PRIMARY KEY,
                           user_id uuid NOT NULL,
                           name varchar(255) NOT NULL,
                           is_public boolean NOT NULL,
                           created_at timestamp NULL,
                           updated_at timestamp NULL,
                           FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE tags (
                      id uuid PRIMARY KEY,
                      name varchar(255) NOT NULL,
                      slug varchar(255) NOT NULL UNIQUE,
                      created_at timestamp NULL,
                      updated_at timestamp NULL
);

CREATE TABLE people (
                        id uuid PRIMARY KEY,
                        name varchar(255) NOT NULL,
                        role varchar(32) NOT NULL,
                        avatar varchar(255) NULL,
                        bio text NULL,
                        created_at timestamp NULL,
                        updated_at timestamp NULL
);

CREATE TABLE menus (
                       id uuid PRIMARY KEY,
                       name varchar(255) NOT NULL,
                       slug varchar(255) NULL,
                       type varchar(32) NOT NULL,
                       reference_id uuid NULL,
                       parent_id uuid NULL,
                       url varchar(255) NULL,
                       position int NOT NULL,
                       is_active boolean NOT NULL,
                       created_at timestamp NULL,
                       updated_at timestamp NULL,
                       FOREIGN KEY (parent_id) REFERENCES menus(id)
);

CREATE TABLE ads (
                     id uuid PRIMARY KEY,
                     image varchar(255) NOT NULL,
                     link varchar(255) NULL,
                     position varchar(32) NOT NULL,
                     ad_order int NOT NULL,
                     start_at timestamp NULL,
                     end_at timestamp NULL,
                     status boolean NOT NULL,
                     created_at timestamp NULL,
                     updated_at timestamp NULL
);

CREATE TABLE activity_logs (
                               id uuid PRIMARY KEY,
                               user_id uuid NULL,
                               action varchar(255) NOT NULL,
                               data_before json NULL,
                               data_after json NULL,
                               created_at timestamp NULL,
                               updated_at timestamp NULL,
                               FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Pivot tables (no id)
CREATE TABLE movie_genre (
                             movie_id uuid NOT NULL,
                             genre_id uuid NOT NULL,
                             PRIMARY KEY (movie_id, genre_id),
                             FOREIGN KEY (movie_id) REFERENCES movies(id),
                             FOREIGN KEY (genre_id) REFERENCES genres(id)
);

CREATE TABLE favorites (
                           user_id uuid NOT NULL,
                           movie_id uuid NOT NULL,
                           created_at timestamp NULL,
                           updated_at timestamp NULL,
                           PRIMARY KEY (user_id, movie_id),
                           FOREIGN KEY (user_id) REFERENCES users(id),
                           FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE TABLE playlist_movie (
                                playlist_id uuid NOT NULL,
                                movie_id uuid NOT NULL,
                                position int NOT NULL,
                                PRIMARY KEY (playlist_id, movie_id),
                                FOREIGN KEY (playlist_id) REFERENCES playlists(id),
                                FOREIGN KEY (movie_id) REFERENCES movies(id)
);

CREATE TABLE movie_tag (
                           movie_id uuid NOT NULL,
                           tag_id uuid NOT NULL,
                           PRIMARY KEY (movie_id, tag_id),
                           FOREIGN KEY (movie_id) REFERENCES movies(id),
                           FOREIGN KEY (tag_id) REFERENCES tags(id)
);

CREATE TABLE movie_people (
                              movie_id uuid NOT NULL,
                              person_id uuid NOT NULL,
                              role varchar(32) NOT NULL,
                              PRIMARY KEY (movie_id, person_id, role),
                              FOREIGN KEY (movie_id) REFERENCES movies(id),
                              FOREIGN KEY (person_id) REFERENCES people(id)
);
