-- +goose Up
-- +goose StatementBegin
CREATE TABLE things(
  id bigserial PRIMARY KEY,
  name text NOT NULL
);

INSERT INTO things(name)
  VALUES ('CAT');

INSERT INTO things(name)
  VALUES ('DOG');

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
DROP TABLE things;

-- +goose StatementEnd
