package org.example.demo;

public class Post {
    private int postId;
    private String postText;

    public Post(int postId, String postText) {
        this.postId = postId;
        this.postText = postText;
    }

    public int getPostId() { 
        return postId;
    }

    public String getPostText() { 
        return postText;
    }
}
