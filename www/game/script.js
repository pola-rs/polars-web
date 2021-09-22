// identify the various objects to keep track of
// lists of "random" objects are given as arrays

const sky = document.getElementById("sky");
const bear = document.getElementById("bear");

const evilHurdles = [
  "snowman",
  "snowmen",
];
const hurdle = document.getElementById("hurdle");

const arcticStuff = [
  "bear",
  "igloo",
  "igloos",
  "penguin",
  "penguins",
  "pups",
  "seal",
  "seals",
];
const stuff1 = document.getElementById("stuff1");
const stuff2 = document.getElementById("stuff2");
const stuff3 = document.getElementById("stuff3");

// add and remove the "jump" class from the bear div
// listen to *any* key stroke

function jump() {
  if (bear.classList != "jump" && hurdle.style.animationPlayState != "paused") {
    bear.classList.add("jump");
    setTimeout(() => {
      bear.classList.remove("jump");
    }, 800);
  }
}

document.addEventListener("keydown", (event) => {
  jump();
});

// check for obstacle every 100 ms by checking position
// if all good, go on with animation
// if hitting a snowman, pause all css animations and slide the bear

const runningBear = setInterval(() => {
  let bearTop = parseInt(window.getComputedStyle(bear).getPropertyValue("top"));
  let hurdleLeft = parseInt(
    window.getComputedStyle(hurdle).getPropertyValue("left")
  );

  if (bearTop >= 100 && hurdleLeft > 50 && hurdleLeft < 110) {
    sky.style.animationPlayState = "paused";

    bear.style.animation = undefined;
    bear.style.backgroundImage = "var(--bear-sliding)";
    bear.style.left = "150px";
    hurdle.style.animationPlayState = "paused";

    stuff1.style.animationPlayState = "paused";
    stuff2.style.animationPlayState = "paused";
    stuff3.style.animationPlayState = "paused";

    window.clearInterval(runningBear);
  }
}, 100);

// logic to randomize the various elements of the landscape
// pick a random element from the given array
// move it slightly (+/- 5 px) vertically, because why not

function randomize(element, items, prefix = "arctic", shift = true) {
  let item = items[Math.floor(Math.random() * items.length)];
  element.style.backgroundImage = "var(--" + prefix + "-" + item + ")";

  if (shift) {
    let elementTop = parseInt(
      window.getComputedStyle(element).getPropertyValue("top")
    );
    let fuzz = Math.floor(Math.random() * 11 - 5);

    element.style.top = 180 + fuzz + "px";
  }
}

// random snowman hurdle
// timeout and intervals should be identical to the css values

const randomHurdle = setInterval(() => {
  if (hurdle.style.animationPlayState === "paused") {
    window.clearInterval(randomHurdle);
  } else {
    randomize(hurdle, evilHurdles, "hurdle", false);
  }
}, 4000);

// random objects roaming the ice
// timeout and intervals should be identical to the css values

setTimeout(() => {
  const randomStuff1 = setInterval(() => {
    if (stuff1.style.animationPlayState === "paused") {
      window.clearInterval(randomStuff1);
    } else {
      randomize(stuff1, arcticStuff);
    }
  }, 3800);  // css
}, 1250);    // css

setTimeout(() => {
  const randomStuff2 = setInterval(() => {
    if (stuff2.style.animationPlayState === "paused") {
      window.clearInterval(randomStuff2);
    } else {
      randomize(stuff2, arcticStuff);
    }
  }, 3800);  // css
}, 2500);    // css

setTimeout(() => {
  const randomStuff3 = setInterval(() => {
    if (stuff3.style.animationPlayState === "paused") {
      window.clearInterval(randomStuff3);
    } else {
      randomize(stuff3, arcticStuff);
    }
  }, 3800);  // css
}, 3750);    // css
