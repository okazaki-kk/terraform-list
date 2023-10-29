package main

import (
	"time"
)

type Thread struct {
	Id        int
	Uuid      string
	Topic     string
	UserId    int
	CreatedAt time.Time
}

type Post struct {
	Id        int
	Uuid      string
	Body      string
	UserId    int
	ThreadId  int
	CreatedAt time.Time
}

// format the CreatedAt date to display nicely on the screen
func (thread *Thread) CreatedAtDate() string {
	return thread.CreatedAt.Format("Jan 2, 2006 at 3:04pm")
}

func (post *Post) CreatedAtDate() string {
	return post.CreatedAt.Format("Jan 2, 2006 at 3:04pm")
}

// get the number of posts in a thread
func (thread *Thread) NumReplies() (count int) {
	stmt := "SELECT count(*) FROM posts where thread_id = ?"
	info(stmt, thread.Id)

	rows, err := Db.Query(stmt, thread.Id)
	if err != nil {
		return
	}
	for rows.Next() {
		if err = rows.Scan(&count); err != nil {
			return
		}
	}
	rows.Close()
	return
}

// get posts to a thread
func (thread *Thread) Posts() (posts []Post, err error) {
	stmt := "SELECT id, uuid, body, user_id, thread_id, created_at FROM posts where thread_id = ?"
	info(stmt, thread.Id)

	rows, err := Db.Query(stmt, thread.Id)
	if err != nil {
		return
	}
	for rows.Next() {
		post := Post{}
		if err = rows.Scan(&post.Id, &post.Uuid, &post.Body, &post.UserId, &post.ThreadId, &post.CreatedAt); err != nil {
			return
		}
		posts = append(posts, post)
	}
	rows.Close()
	return
}

// Create a new thread
func (user *User) CreateThread(topic string) (Thread, error) {
	uuid := createUUID()
	createdAt := time.Now()

	stmt := "insert into threads (uuid, topic, user_id, created_at) values (?, ?, ?, ?)"
	info(stmt, uuid, topic, user.Id, createdAt)

	res, err := Db.Exec(stmt, uuid, topic, user.Id, createdAt)
	if err != nil {
		return Thread{}, err
	}

	// Get the last insert id
	id, err := res.LastInsertId()
	if err != nil {
		return Thread{}, err
	}

	conv := Thread{
		Id:        int(id),
		Uuid:      uuid,
		Topic:     topic,
		UserId:    user.Id,
		CreatedAt: createdAt,
	}
	return conv, nil
}

// Create a new post to a thread
func (user *User) CreatePost(conv Thread, body string) (Post, error) {
	uuid := createUUID()
	createdAt := time.Now()

	stmt := "insert into posts (uuid, body, user_id, thread_id, created_at) values (?, ?, ?, ?, ?)"
	info(stmt, uuid, body, user.Id, conv.Id, createdAt)

	res, err := Db.Exec(stmt, uuid, body, user.Id, conv.Id, createdAt)
	if err != nil {
		return Post{}, err
	}

	// Get the last insert id
	id, err := res.LastInsertId()
	if err != nil {
		return Post{}, err
	}

	post := Post{
		Id:        int(id),
		Uuid:      uuid,
		Body:      body,
		UserId:    user.Id,
		ThreadId:  conv.Id,
		CreatedAt: createdAt,
	}
	return post, nil
}

// Get all threads in the database and returns it
func Threads() (threads []Thread, err error) {
	stmt := "SELECT id, uuid, topic, user_id, created_at FROM threads ORDER BY created_at DESC"
	info(stmt)
	rows, err := Db.Query(stmt)
	if err != nil {
		return
	}
	for rows.Next() {
		conv := Thread{}
		if err = rows.Scan(&conv.Id, &conv.Uuid, &conv.Topic, &conv.UserId, &conv.CreatedAt); err != nil {
			return
		}
		threads = append(threads, conv)
	}
	rows.Close()
	return
}

// Get a thread by the UUID
func ThreadByUUID(uuid string) (conv Thread, err error) {
	conv = Thread{}
	stmt := "SELECT id, uuid, topic, user_id, created_at FROM threads WHERE uuid = ?"
	info(stmt, uuid)
	err = Db.QueryRow(stmt, uuid).
		Scan(&conv.Id, &conv.Uuid, &conv.Topic, &conv.UserId, &conv.CreatedAt)
	return
}

// Get the user who started this thread
func (thread *Thread) User() (user User) {
	user = User{}
	stmt := "SELECT id, uuid, name, email, created_at FROM users WHERE id = ?"
	info(stmt, thread.UserId)
	Db.QueryRow(stmt, thread.UserId).
		Scan(&user.Id, &user.Uuid, &user.Name, &user.Email, &user.CreatedAt)
	return
}

// Get the user who wrote the post
func (post *Post) User() (user User) {
	user = User{}
	stmt := "SELECT id, uuid, name, email, created_at FROM users WHERE id = ?"
	info(stmt, post.UserId)
	Db.QueryRow(stmt, post.UserId).
		Scan(&user.Id, &user.Uuid, &user.Name, &user.Email, &user.CreatedAt)
	return
}
