using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingPlatform : MonoBehaviour
{
    Rigidbody2D rb2d;
    float horizontal = -1;

    [SerializeField] float speed = 2;

    void Start()
    {
        rb2d = GetComponent<Rigidbody2D>();
    }

    // Update is called once per frame
    void Update()
    {
        rb2d.linearVelocity = new Vector2(horizontal * speed, rb2d.linearVelocity.y);
    }

    void OnTriggerEnter2D(Collider2D col)
    {
        horizontal *= -1;
    }
}
