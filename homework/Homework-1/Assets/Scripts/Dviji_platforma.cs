using UnityEngine;

public class Dviji_platforma : MonoBehaviour
{
    Rigidbody2D rb2d;
    float posoka = -1;

    [SerializeField]
    float skorost = 3;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        rb2d = GetComponent<Rigidbody2D>();
    }

    // Update is called once per frame
    void Update()
    {
        rb2d.linearVelocity = new Vector2(rb2d.linearVelocity.x, posoka * skorost);
    }

    void OnTriggerEnter2D(Collider2D col)
    {
        posoka *= -1;
    }
}
