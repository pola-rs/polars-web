const sky = document.getElementById("sky");

const bear = document.getElementById("bear");

const evilHurdles = ["snowman", "snowmen"];
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

function jump() {
  if (bear.classList != "jump" && hurdle.style.animationPlayState != "paused") {
    bear.classList.add("jump");
    setTimeout(() => {
      bear.classList.remove("jump");
    }, 800);
  }
}

const runningBear = setInterval(() => {
  let bearTop = parseInt(window.getComputedStyle(bear).getPropertyValue("top"));
  let hurdleLeft = parseInt(
    window.getComputedStyle(hurdle).getPropertyValue("left")
  );

  if (bearTop >= 100 && hurdleLeft > 50 && hurdleLeft < 110) {
    sky.style.animationPlayState = "paused";

    bear.style.animation = undefined;
    bear.style.backgroundImage = 'url("bear-ko.png")';
    bear.style.left = "150px";
    hurdle.style.animationPlayState = "paused";

    stuff1.style.animationPlayState = "paused";
    stuff2.style.animationPlayState = "paused";
    stuff3.style.animationPlayState = "paused";

    window.clearInterval(runningBear);
  }
}, 100);

function randomize(element, items, prefix = "", shift = true) {
  let item = items[Math.floor(Math.random() * items.length)];
  element.style.backgroundImage = 'url("' + prefix + item + '.png")';

  if (shift) {
    let elementTop = parseInt(
      window.getComputedStyle(element).getPropertyValue("top")
    );
    let fuzz = Math.floor(Math.random() * 11 - 5);

    element.style.top = 180 + fuzz + "px";
  }
}

const randomHurdle = setInterval(() => {
  if (hurdle.style.animationPlayState === "paused") {
    window.clearInterval(randomHurdle);
  } else {
    randomize(hurdle, evilHurdles, "hurdle-", false);
  }
}, 4000);

setTimeout(() => {
  const randomStuff1 = setInterval(() => {
    if (hurdle.style.animationPlayState === "paused") {
      window.clearInterval(randomStuff1);
    } else {
      randomize(stuff1, arcticStuff, "arctic-");
    }
  }, 3800);
}, 1250);

setTimeout(() => {
  const randomStuff2 = setInterval(() => {
    if (hurdle.style.animationPlayState === "paused") {
      window.clearInterval(randomStuff2);
    } else {
      randomize(stuff2, arcticStuff, "arctic-");
    }
  }, 3800);
}, 2500);

setTimeout(() => {
  const randomStuff3 = setInterval(() => {
    if (hurdle.style.animationPlayState === "paused") {
      window.clearInterval(randomStuff3);
    } else {
      randomize(stuff3, arcticStuff, "arctic-");
    }
  }, 3800);
}, 3750);

document.addEventListener("keydown", (event) => {
  jump();
});
