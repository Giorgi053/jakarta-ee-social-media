package org.example.demo;

public class Post {
    private int postId;
    private String postText;

    public Post(int postId, String postText) {
        this.postId = postId;
        this.postText = postText;
    }

    public int getPostId() { // ✅ Required for ${post.postId}
        return postId;
    }

    public String getPostText() { // ✅ Required for ${post.postText}
        return postText;
    }
}
