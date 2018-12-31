function vote(post_id, up) {
    tag = up ? "up" : "down"
    upvote_button = document.getElementById("up_" + post_id);
    downvote_button = document.getElementById("down_" + post_id);
    score = document.getElementById("score_" + post_id);
    previousScore = parseInt(score.innerHTML)
    scoreChange = 1
    upvoteSelected = upvote_button.classList.contains("selected")
    downvoteSelected = downvote_button.classList.contains("selected")

    if ((upvoteSelected && up) || (downvoteSelected && !up)) {
        return false
    }

    if (upvoteSelected || downvoteSelected) {
        scoreChange = 2
    }
    
    if (up) {
        upvote_button.classList.add("selected");
        downvote_button.classList.remove("selected");
        score.innerHTML = previousScore + scoreChange
    } else {
        upvote_button.classList.remove("selected");
        downvote_button.classList.add("selected");
        score.innerHTML = previousScore - scoreChange
    }

    var xhr = new XMLHttpRequest();
    xhr.open("POST", '/vote', true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({
        post_id: post_id,
        up: up
    }));

    return false
}