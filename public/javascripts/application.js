function checkDuration(form) {
    var val = parseInt(form['user_activity[duration]'].value, 10);
    if(isNaN(val)) {
        alert('You must enter a valid duration.');
        return false;
    } else {
        return true;
    }
}

function checkWeight(form) {
    var val = parseInt(form['weight_tracker[weight]'].value, 10);
    if (isNaN(val)){
        alert('You must enter a valid weight.');
        return false;
    } else {
        return true;
    }
}

function checkMeal(form) {
    var val = parseFloat(form['meal[servings]'].value, 10);
    if(isNaN(val)) {
        alert('You must enter a number of servings before you can add this food.');
        return false;
    } else {
        return true;
    }
}