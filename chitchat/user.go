package main

import (
	"time"
)

type User struct {
	Id        int
	Uuid      string
	Name      string
	Email     string
	Password  string
	CreatedAt time.Time
}

type Session struct {
	Id        int
	Uuid      string
	Email     string
	UserId    int
	CreatedAt time.Time
}

// Create a new session for an existing user
func (user *User) CreateSession() (Session, error) {
	uuid := createUUID()
	createdAt := time.Now()

	stmt := "insert into sessions (uuid, email, user_id, created_at) values (?, ?, ?, ?)"
	info(stmt, uuid, user.Email, user.Id, createdAt)

	res, err := Db.Exec(stmt, uuid, user.Email, user.Id, createdAt)
	if err != nil {
		return Session{}, err
	}

	// Get the last insert id
	id, err := res.LastInsertId()
	if err != nil {
		return Session{}, err
	}

	session := Session{
		Id:        int(id),
		Uuid:      uuid,
		Email:     user.Email,
		UserId:    user.Id,
		CreatedAt: createdAt,
	}
	return session, nil
}

// Get the session for an existing user
func (user *User) Session() (session Session, err error) {
	session = Session{}
	stmt := "SELECT id, uuid, email, user_id, created_at from sessions where user_id = ?"

	err = Db.QueryRow(stmt, user.Id).
		Scan(&session.Id, &session.Uuid, &session.Email, &session.UserId, &session.CreatedAt)
	return
}

// Check if session is valid in the database
func (session *Session) Check() (valid bool, err error) {
	stmt := "SELECT id, uuid, email, user_id, created_at FROM sessions WHERE uuid = ?"
	info(stmt, session.Uuid)

	err = Db.QueryRow(stmt, session.Uuid).
		Scan(&session.Id, &session.Uuid, &session.Email, &session.UserId, &session.CreatedAt)
	if err != nil {
		valid = false
		return
	}
	if session.Id != 0 {
		valid = true
	}
	return
}

// Delete session from database
func (session *Session) DeleteByUUID() (err error) {
	statement := "delete from sessions where uuid = ?"
	info(statement, session.Uuid)
	stmt, err := Db.Prepare(statement)
	if err != nil {
		return
	}
	defer stmt.Close()

	_, err = stmt.Exec(session.Uuid)
	return
}

// Get the user from the session
func (session *Session) User() (user User, err error) {
	user = User{}
	stmt := "SELECT id, uuid, name, email, created_at FROM users WHERE id = ?"
	info(stmt, session.UserId)

	err = Db.QueryRow(stmt, session.UserId).
		Scan(&user.Id, &user.Uuid, &user.Name, &user.Email, &user.CreatedAt)
	return
}

// Delete all sessions from database
func SessionDeleteAll() (err error) {
	statement := "delete from sessions"
	_, err = Db.Exec(statement)
	return
}

// Create a new user, save user info into the database
func (user *User) Create() error {
	uuid := createUUID()
	createdAt := time.Now()

	stmt := "insert into users (uuid, name, email, password, created_at) values (?, ?, ?, ?, ?)"
	info(stmt, uuid, user.Name, user.Email, Encrypt(user.Password), createdAt)

	res, err := Db.Exec(stmt, uuid, user.Name, user.Email, Encrypt(user.Password), createdAt)
	if err != nil {
		return err
	}

	// Get the last insert id
	id, err := res.LastInsertId()
	if err != nil {
		return err
	}

	user.Id = int(id)
	user.Uuid = uuid
	user.CreatedAt = createdAt
	return nil
}

// Delete user from database
func (user *User) Delete() (err error) {
	statement := "delete from users where id = ?"
	info(statement, user.Id)
	stmt, err := Db.Prepare(statement)
	if err != nil {
		return
	}
	defer stmt.Close()

	_, err = stmt.Exec(user.Id)
	return
}

// Update user information in the database
func (user *User) Update() (err error) {
	statement := "update users set name = ?, email = ? where id = ?"
	info(statement, user.Name, user.Email, user.Id)
	stmt, err := Db.Prepare(statement)
	if err != nil {
		return
	}
	defer stmt.Close()

	_, err = stmt.Exec(user.Name, user.Email, user.Id)
	return
}

// Delete all users from database
func UserDeleteAll() (err error) {
	statement := "delete from users"
	_, err = Db.Exec(statement)
	return
}

// Get all users in the database and returns it
func Users() (users []User, err error) {
	stmt := "SELECT id, uuid, name, email, password, created_at FROM users"
	info(stmt)
	rows, err := Db.Query(stmt)
	if err != nil {
		return
	}
	for rows.Next() {
		user := User{}
		if err = rows.Scan(&user.Id, &user.Uuid, &user.Name, &user.Email, &user.Password, &user.CreatedAt); err != nil {
			return
		}
		users = append(users, user)
	}
	rows.Close()
	return
}

// Get a single user given the email
func UserByEmail(email string) (user User, err error) {
	user = User{}
	stmt := "SELECT id, uuid, name, email, password, created_at FROM users WHERE email = ?"
	info(stmt, email)
	err = Db.QueryRow(stmt, email).
		Scan(&user.Id, &user.Uuid, &user.Name, &user.Email, &user.Password, &user.CreatedAt)
	return
}

// Get a single user given the UUID
func UserByUUID(uuid string) (user User, err error) {
	user = User{}
	stmt := "SELECT id, uuid, name, email, password, created_at FROM users WHERE uuid = ?"
	info(stmt, uuid)
	err = Db.QueryRow(stmt, uuid).
		Scan(&user.Id, &user.Uuid, &user.Name, &user.Email, &user.Password, &user.CreatedAt)
	return
}
