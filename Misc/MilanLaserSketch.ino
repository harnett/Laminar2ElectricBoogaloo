#include <Event.h>
#include <Timer.h>
#include <LED.h>
#define A_Pin A0
#define B_Pin A0
// should include off+on durations for each laser
// array size should be even
int A_times[] = {1000,300};
int B_times[] = {500,500};
/*******************************************************************************************************************/
template <typename T>
class Sequence {
  public:
    size_t len;
    T *ary;
    int count;
    T current;
    Sequence() {
      count = 0;
      this->current = 0;
    }
    Sequence(T* ary, size_t len) {
      this->ary = ary;
      this->len = len;
      count = 0;
      this->current = ary[count];
    }
    T next() {
      ++count;
      int ind = count % len;
      this->current = ary[ind];
      return current;
    }
    T randNext() {
      this->current =  ary[random(len)];
      return current;
    }
    void reset() {
      this->count = 0;
      this->current = ary[this->count];
    }
    void setCurrent(T n) {
      current = n;
    }
};
Timer t; 
Timer h;
int tids[50];
size_t A_times_size = sizeof(A_times) / sizeof(A_times[0]);
size_t B_times_size = sizeof(B_times) / sizeof(B_times[0]);
Sequence<int> a_sequence (A_times, A_times_size);
Sequence<int> b_sequence (B_times, B_times_size);
bool programRunning = false;
void serLog(String str) {
  Serial.print(millis());
  Serial.print(" ");
  Serial.print(str);
  Serial.print("\n");
}
void stopTimers() {
  for (auto tid : tids) t.stop(tid);
  for (auto tid : tids) h.stop(tid);
}
void A_activate() {
  serLog("A on");
  digitalWrite(A_Pin, HIGH);
  
  tids[3] = h.after(a_sequence.next(), [] () {
    serLog("A off");
    digitalWrite(A_Pin, LOW);
    tids[4] = t.after(a_sequence.next(), A_activate);
  });
}
void B_activate() {
    serLog("B on");
  digitalWrite(A_Pin, HIGH);
  
  tids[5] = h.after(b_sequence.next(), [] () {
    serLog("B off");
    digitalWrite(A_Pin, LOW);
    tids[6] = t.after(b_sequence.next(), B_activate);
  });
}
void setup() {
  Serial.begin(115200);
  if (A_times_size%2 != 0) serLog("Warning: A_times isn't even");
  if (B_times_size%2 != 0) serLog("Warning: B_times isn't even");
  delay(1000);
  Serial.println("Press 'p' to play or pause.");
}
void loop() {
  if (Serial.available() > 0 && Serial.read() == 'p') {
      programRunning = !programRunning;
      if (!programRunning) { Serial.println("Paused. Press 'p' to restart."); stopTimers(); }
      else {
        a_sequence.reset();
        b_sequence.reset();
        tids[1] = t.after(a_sequence.current, A_activate);
        tids[2] = t.after(b_sequence.current, B_activate);
      }
  }
  if (programRunning) {
    t.update();
    h.update();
  }
  else {
    digitalWrite(A_Pin, LOW);
    digitalWrite(B_Pin, LOW);
  }
}
